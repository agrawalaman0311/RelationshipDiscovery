import streamlit as st
import altair as alt
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Enterprise Product MDM Dashboard", layout="wide")

session = get_active_session()


@st.cache_data(ttl=300)
def run_query(sql):
    try:
        return session.sql(sql).to_pandas()
    except Exception as e:
        st.error(f"Query failed: {e}")
        return pd.DataFrame()


@st.cache_data(ttl=300)
def get_final_master():
    return run_query("SELECT * FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER")


@st.cache_data(ttl=300)
def get_action_log():
    return run_query("SELECT * FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG")


@st.cache_data(ttl=300)
def get_intm_master():
    return run_query(
        "SELECT ENTITY_KEY, VERSION_NO, ACTION_SOURCE, ACTIVE_FLAG, CREATED_DTTM, UPDATED_DTTM "
        "FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER ORDER BY ENTITY_KEY, VERSION_NO"
    )


@st.cache_data(ttl=300)
def get_dq_rules():
    return run_query("SELECT * FROM RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES")


@st.cache_data(ttl=300)
def get_survivorship():
    return run_query("SELECT * FROM RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP")


@st.cache_data(ttl=300)
def get_attribute_mapping():
    return run_query("SELECT * FROM RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_MAPPING")


st.title("Enterprise Product Master Data Quality & Governance Dashboard")

tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs([
    "Executive Summary", "Lineage & Audit", "Data Quality",
    "MDM Processing", "Metadata & Governance", "MDM Architecture"
])

with tab1:
    st.header("Executive Summary")
    st.caption("Business overview of the mastered product data estate.")

    with st.spinner("Loading..."):
        df_final = get_final_master()
        df_dq_rules = get_dq_rules()
        df_surv = get_survivorship()
        df_mapping = get_attribute_mapping()
        df_actions = get_action_log()

    if df_final.empty:
        st.warning("No data available in FINAL.PRODUCT_MASTER.")
    else:
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Total Products", f"{len(df_final):,}")
        c2.metric("Product Families", int(df_final["DERIVED_PRODUCT_FAMILY"].nunique()))
        c3.metric("Product Groups", int(df_final["DERIVED_PRODUCT_GROUP"].nunique()))
        c4.metric("Product Statuses", int(df_final["DERIVED_PRODUCT_STATUS"].nunique()))

        c5, c6, c7, c8 = st.columns(4)
        active_dq = int((df_dq_rules["ACTIVE_FLAG"] == "Y").sum()) if not df_dq_rules.empty else 0
        active_surv = int((df_surv["ACTIVE_FLAG"] == "Y").sum()) if not df_surv.empty else 0
        active_map = int((df_mapping["ACTIVE_FLAG"] == "Y").sum()) if not df_mapping.empty else 0
        total_actions = len(df_actions) if not df_actions.empty else 0
        c5.metric("Active DQ Rules", active_dq)
        c6.metric("Survivorship Rules", active_surv)
        c7.metric("Attribute Mappings", active_map)
        c8.metric("Total Actions Processed", f"{total_actions:,}")

        st.divider()

        st.subheader("Security Overview")
        s1, s2, s3 = st.columns(3)
        s1.metric("Platform Roles", 4)
        s2.metric("Masking Policies", 3)
        s3.metric("Protected Attributes", 3)

        st.divider()

        col_a, col_b = st.columns(2)

        with col_a:
            family_dist = df_final["DERIVED_PRODUCT_FAMILY"].value_counts().reset_index()
            family_dist.columns = ["PRODUCT_FAMILY", "COUNT"]
            chart = alt.Chart(family_dist).mark_bar(cornerRadiusTopLeft=4, cornerRadiusTopRight=4).encode(
                x=alt.X("PRODUCT_FAMILY:N", sort="-y", title="Product Family", axis=alt.Axis(labelAngle=-45)),
                y=alt.Y("COUNT:Q", title="Count"),
                color=alt.Color("PRODUCT_FAMILY:N", legend=None),
                tooltip=["PRODUCT_FAMILY", "COUNT"]
            ).properties(title="Product Family Distribution", height=380).interactive()
            st.altair_chart(chart, use_container_width=True)

        with col_b:
            group_dist = df_final["DERIVED_PRODUCT_GROUP"].value_counts().reset_index()
            group_dist.columns = ["PRODUCT_GROUP", "COUNT"]
            chart = alt.Chart(group_dist).mark_arc(innerRadius=60).encode(
                theta=alt.Theta("COUNT:Q"),
                color=alt.Color("PRODUCT_GROUP:N", title="Product Group"),
                tooltip=["PRODUCT_GROUP", "COUNT"]
            ).properties(title="Product Group Distribution", height=380)
            st.altair_chart(chart, use_container_width=True)

        status_dist = df_final["DERIVED_PRODUCT_STATUS"].value_counts().reset_index()
        status_dist.columns = ["STATUS", "COUNT"]
        chart = alt.Chart(status_dist).mark_bar(cornerRadiusTopLeft=4, cornerRadiusTopRight=4).encode(
            x=alt.X("STATUS:N", title="Status"),
            y=alt.Y("COUNT:Q", title="Count"),
            color=alt.Color("STATUS:N", scale=alt.Scale(
                domain=["ACTIVE", "REVIEW"], range=["#2ca02c", "#ff7f0e"]), legend=None),
            tooltip=["STATUS", "COUNT"]
        ).properties(title="Product Status Distribution", height=280).interactive()
        st.altair_chart(chart, use_container_width=True)

with tab2:
    st.header("Lineage & Audit")
    st.caption("Version history, entity lineage, and audit trail per ENTITY_KEY.")

    with st.spinner("Loading version history..."):
        df_intm = get_intm_master()

    if df_intm.empty:
        st.warning("No data available in INTM_PRODUCT_MASTER.")
    else:
        entity_keys = sorted(df_intm["ENTITY_KEY"].dropna().unique().tolist())
        selected_entity = st.selectbox("Select ENTITY_KEY", entity_keys, index=0)

        df_entity = df_intm[df_intm["ENTITY_KEY"] == selected_entity].sort_values("VERSION_NO").copy()

        c1, c2, c3 = st.columns(3)
        c1.metric("Total Versions", len(df_entity))
        active_v = df_entity[df_entity["ACTIVE_FLAG"] == "Y"]
        c2.metric("Active Version", int(active_v["VERSION_NO"].max()) if not active_v.empty else "None")
        sources = df_entity["ACTION_SOURCE"].dropna().unique().tolist()
        c3.metric("Action Sources", len(sources))

        st.divider()

        st.subheader("Version Timeline")
        if not df_entity.empty:
            timeline_df = df_entity.copy()
            timeline_df["VERSION_NO"] = timeline_df["VERSION_NO"].astype(int)
            timeline_df["CREATED_DTTM"] = pd.to_datetime(timeline_df["CREATED_DTTM"])
            chart = alt.Chart(timeline_df).mark_circle(size=250).encode(
                x=alt.X("VERSION_NO:O", title="Version Number"),
                y=alt.Y("ACTION_SOURCE:N", title="Action Source"),
                color=alt.Color("ACTION_SOURCE:N", title="Source"),
                size=alt.condition(
                    alt.datum.ACTIVE_FLAG == "Y",
                    alt.value(350),
                    alt.value(150)
                ),
                tooltip=["VERSION_NO", "ACTION_SOURCE", "ACTIVE_FLAG", "CREATED_DTTM", "UPDATED_DTTM"]
            ).properties(title=f"Version Evolution: {selected_entity[:40]}", height=250).interactive()
            st.altair_chart(chart, use_container_width=True)

        st.subheader("Version History")
        st.dataframe(df_entity, use_container_width=True, hide_index=True)

        st.subheader("Lineage Sources")
        lineage_labels = {
            "P_010_MASTER_CREATION": "P10 - Master Creation (Initial Record)",
            "P10_MASTER_CREATION": "P10 - Master Creation (Initial Record)",
            "P12_PRODUCT_FAMILY": "P12 - Product Family Derivation",
            "P13_PRODUCT_GROUP": "P13 - Product Group Derivation",
            "P14_PRODUCT_STATUS": "P14 - Product Status Derivation"
        }
        if sources:
            for src in sources:
                label = lineage_labels.get(src, src if src else "Unknown")
                st.markdown(f"- **{label}**")
        else:
            st.info("No lineage sources recorded.")

with tab3:
    st.header("Data Quality")
    st.caption("Attribute completeness and quality scoring for mastered product data.")

    with st.spinner("Calculating..."):
        df_final = get_final_master()
        df_dq_rules = get_dq_rules()

    if df_final.empty:
        st.warning("No data available for quality assessment.")
    else:
        total = len(df_final)
        attributes = ["BRAND", "PRODUCT_NAME", "CATEGORY", "MANUFACTURER", "SALE_PRICE", "SIZE"]

        critical_attrs = []
        if not df_dq_rules.empty:
            critical_attrs = df_dq_rules[df_dq_rules["IS_CRITICAL"] == "Y"]["ATTRIBUTE_NAME"].tolist()

        completeness = []
        for attr in attributes:
            if attr in df_final.columns:
                populated = int(df_final[attr].notna().sum())
            else:
                populated = 0
            pct = round((populated / total) * 100, 1) if total > 0 else 0.0
            missing = total - populated
            attr_type = "Critical" if attr in critical_attrs else "Standard"
            completeness.append({
                "Attribute": attr, "Populated": populated, "Missing": missing,
                "Completeness": pct, "Type": attr_type
            })

        df_comp = pd.DataFrame(completeness)
        overall_score = round(float(df_comp["Completeness"].mean()), 1)

        c1, c2, c3 = st.columns(3)
        c1.metric("Overall DQ Score", f"{overall_score}%")
        c2.metric("Total Records", f"{total:,}")
        c3.metric("Critical Attributes", len(critical_attrs))

        st.divider()

        col_a, col_b = st.columns([2, 1])
        with col_a:
            chart = alt.Chart(df_comp).mark_bar(cornerRadiusEnd=4).encode(
                y=alt.Y("Attribute:N", sort=None, title="Attribute"),
                x=alt.X("Completeness:Q", scale=alt.Scale(domain=[0, 105]), title="Completeness %"),
                color=alt.Color("Type:N", scale=alt.Scale(
                    domain=["Critical", "Standard"], range=["#d62728", "#1f77b4"]), title="Attribute Type"),
                tooltip=["Attribute", "Completeness", "Type", "Populated", "Missing"]
            ).properties(title="Attribute Completeness", height=300).interactive()
            st.altair_chart(chart, use_container_width=True)

        with col_b:
            st.subheader("Completeness Details")
            st.dataframe(df_comp, use_container_width=True, hide_index=True)

        with st.expander("Missing Value Analysis"):
            missing_df = df_comp[df_comp["Missing"] > 0]
            if not missing_df.empty:
                chart = alt.Chart(missing_df).mark_bar(cornerRadiusEnd=4).encode(
                    y=alt.Y("Attribute:N", title="Attribute"),
                    x=alt.X("Missing:Q", title="Missing Count"),
                    color=alt.Color("Type:N", scale=alt.Scale(
                        domain=["Critical", "Standard"], range=["#d62728", "#ff7f0e"])),
                    tooltip=["Attribute", "Missing", "Type"]
                ).properties(height=250).interactive()
                st.altair_chart(chart, use_container_width=True)
            else:
                st.success("No missing values detected!")

with tab4:
    st.header("MDM Processing")
    st.caption("Monitor ACTION_LOG execution, action types, and processing status.")

    with st.spinner("Loading action log..."):
        df_actions = get_action_log()

    if df_actions.empty:
        st.warning("No actions found in ACTION_LOG.")
    else:
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Total Actions", f"{len(df_actions):,}")
        c2.metric("CREATE", f"{int((df_actions['ACTION_TYPE'] == 'CREATE').sum()):,}")
        c3.metric("UPDATE", f"{int((df_actions['ACTION_TYPE'] == 'UPDATE').sum()):,}")
        c4.metric("DELETE", f"{int((df_actions['ACTION_TYPE'] == 'DELETE').sum()):,}")

        st.divider()

        status_counts = df_actions["ACTION_STATUS"].value_counts()
        c5, c6, c7, c8 = st.columns(4)
        c5.metric("COMPLETED", f"{int(status_counts.get('COMPLETED', 0)):,}")
        c6.metric("FAILED", f"{int(status_counts.get('FAILED', 0)):,}")
        c7.metric("SKIPPED", f"{int(status_counts.get('SKIPPED', 0)):,}")
        c8.metric("PENDING", f"{int(status_counts.get('PENDING', 0)):,}")

        st.divider()
        col_a, col_b = st.columns(2)

        with col_a:
            status_df = df_actions["ACTION_STATUS"].value_counts().reset_index()
            status_df.columns = ["STATUS", "COUNT"]
            chart = alt.Chart(status_df).mark_arc(innerRadius=60).encode(
                theta=alt.Theta("COUNT:Q"),
                color=alt.Color("STATUS:N", scale=alt.Scale(
                    domain=["COMPLETED", "FAILED", "SKIPPED", "PENDING"],
                    range=["#2ca02c", "#d62728", "#ff7f0e", "#1f77b4"]), title="Status"),
                tooltip=["STATUS", "COUNT"]
            ).properties(title="Actions By Status", height=350)
            st.altair_chart(chart, use_container_width=True)

        with col_b:
            type_df = df_actions["ACTION_TYPE"].value_counts().reset_index()
            type_df.columns = ["TYPE", "COUNT"]
            chart = alt.Chart(type_df).mark_bar(cornerRadiusTopLeft=4, cornerRadiusTopRight=4).encode(
                x=alt.X("TYPE:N", title="Action Type"),
                y=alt.Y("COUNT:Q", title="Count"),
                color=alt.Color("TYPE:N", legend=None),
                tooltip=["TYPE", "COUNT"]
            ).properties(title="Actions By Type", height=350).interactive()
            st.altair_chart(chart, use_container_width=True)

        if "ACTION_SOURCE" in df_actions.columns:
            source_df = df_actions["ACTION_SOURCE"].dropna().value_counts().reset_index()
            source_df.columns = ["SOURCE", "COUNT"]
            if not source_df.empty:
                chart = alt.Chart(source_df).mark_bar(cornerRadiusEnd=4).encode(
                    y=alt.Y("SOURCE:N", sort="-x", title="Action Source"),
                    x=alt.X("COUNT:Q", title="Count"),
                    color=alt.Color("SOURCE:N", legend=None),
                    tooltip=["SOURCE", "COUNT"]
                ).properties(title="Actions By Source", height=250).interactive()
                st.altair_chart(chart, use_container_width=True)

        with st.expander("Latest Actions (first 200 rows)"):
            st.dataframe(df_actions.head(200), use_container_width=True, hide_index=True)

with tab5:
    st.header("Metadata & Governance")
    st.caption("Data Quality rules, Survivorship configuration, and Attribute Mappings.")

    with st.spinner("Loading metadata..."):
        df_dq_rules = get_dq_rules()
        df_surv = get_survivorship()
        df_mapping = get_attribute_mapping()

    st.subheader("1. Data Quality Rules")
    if df_dq_rules.empty:
        st.info("No DQ rules found.")
    else:
        active_rules = df_dq_rules[df_dq_rules["ACTIVE_FLAG"] == "Y"].copy()
        critical_count = int((active_rules["IS_CRITICAL"] == "Y").sum())

        c1, c2, c3 = st.columns(3)
        c1.metric("Total Active Rules", len(active_rules))
        c2.metric("Critical Attributes", critical_count)
        c3.metric("Non-Critical", len(active_rules) - critical_count)

        col_a, col_b = st.columns(2)
        with col_a:
            crit_df = active_rules["IS_CRITICAL"].value_counts().reset_index()
            crit_df.columns = ["TYPE", "COUNT"]
            crit_df["TYPE"] = crit_df["TYPE"].map({"Y": "Critical", "N": "Non-Critical"})
            chart = alt.Chart(crit_df).mark_arc(innerRadius=50).encode(
                theta=alt.Theta("COUNT:Q"),
                color=alt.Color("TYPE:N", scale=alt.Scale(
                    domain=["Critical", "Non-Critical"], range=["#d62728", "#1f77b4"])),
                tooltip=["TYPE", "COUNT"]
            ).properties(title="Critical vs Non-Critical", height=280)
            st.altair_chart(chart, use_container_width=True)

        with col_b:
            if "DQ_RULE_TYPE" in active_rules.columns:
                type_df = active_rules["DQ_RULE_TYPE"].dropna().value_counts().reset_index()
                type_df.columns = ["RULE_TYPE", "COUNT"]
                if not type_df.empty:
                    chart = alt.Chart(type_df).mark_bar(cornerRadiusTopLeft=4, cornerRadiusTopRight=4).encode(
                        x=alt.X("RULE_TYPE:N", title="Rule Type"),
                        y=alt.Y("COUNT:Q", title="Count"),
                        color=alt.Color("RULE_TYPE:N", legend=None),
                        tooltip=["RULE_TYPE", "COUNT"]
                    ).properties(title="DQ Rules By Type", height=280).interactive()
                    st.altair_chart(chart, use_container_width=True)

        with st.expander("DQ Rules Table"):
            st.dataframe(active_rules, use_container_width=True, hide_index=True)

    st.divider()

    st.subheader("2. Survivorship Rules")
    if df_surv.empty:
        st.info("No survivorship rules found.")
    else:
        active_surv = df_surv[df_surv["ACTIVE_FLAG"] == "Y"].copy()
        st.metric("Active Survivorship Rules", len(active_surv))

        surv_sorted = active_surv.sort_values(["ATTRIBUTE_NAME", "PRIORITY_ORDER"])
        chart = alt.Chart(surv_sorted).mark_bar(cornerRadiusEnd=4).encode(
            y=alt.Y("SOURCE_SYSTEM:N", title="Source System"),
            x=alt.X("PRIORITY_ORDER:Q", title="Priority (1 = Highest)"),
            color=alt.Color("SOURCE_SYSTEM:N", legend=None),
            row=alt.Row("ATTRIBUTE_NAME:N", title="Attribute"),
            tooltip=["ATTRIBUTE_NAME", "SOURCE_SYSTEM", "PRIORITY_ORDER"]
        ).properties(height=60, width=400).interactive()
        st.altair_chart(chart, use_container_width=False)

        with st.expander("Survivorship Rules Table"):
            st.dataframe(surv_sorted, use_container_width=True, hide_index=True)

    st.divider()

    st.subheader("3. Security Architecture")

    security_controls = pd.DataFrame([
        {"Security Control": "RBAC", "Status": "Enabled"},
        {"Security Control": "Dynamic Masking", "Status": "Enabled"},
        {"Security Control": "Row Level Security", "Status": "Not Implemented"},
        {"Security Control": "OAuth", "Status": "Out of Scope"},
        {"Security Control": "MFA", "Status": "Out of Scope"},
        {"Security Control": "ABAC", "Status": "Out of Scope"},
    ])
    st.dataframe(security_controls, use_container_width=True, hide_index=True)

    protected_attrs = pd.DataFrame([
        {"Attribute": "SALE_PRICE", "Protection Policy": "MASK_SALE_PRICE"},
        {"Attribute": "SOURCE_EXECUTION_REFERENCE", "Protection Policy": "MASK_SOURCE_EXECUTION_REFERENCE"},
        {"Attribute": "ACTION_SOURCE", "Protection Policy": "MASK_ACTION_SOURCE"},
    ])
    st.dataframe(protected_attrs, use_container_width=True, hide_index=True)

    coverage_df = pd.DataFrame([
        {"Attribute": "SALE_PRICE", "Protected": 1},
        {"Attribute": "SOURCE_EXECUTION_REFERENCE", "Protected": 1},
        {"Attribute": "ACTION_SOURCE", "Protected": 1},
    ])
    chart = alt.Chart(coverage_df).mark_bar(cornerRadiusEnd=4, color="#2ca02c").encode(
        y=alt.Y("Attribute:N", title="Protected Attribute"),
        x=alt.X("Protected:Q", title="Protection Enabled", scale=alt.Scale(domain=[0, 1.2])),
        tooltip=["Attribute"]
    ).properties(title="Security Coverage – Protected Attributes", height=150)
    st.altair_chart(chart, use_container_width=True)

    st.info(
        "Security is governed using the same architecture principles as metadata, business rules and lineage. "
        "The platform implements:\n\n"
        "- Role Based Access Control\n"
        "- Dynamic Data Masking\n\n"
        "while intentionally excluding:\n\n"
        "- Row Level Security\n"
        "- OAuth\n"
        "- MFA\n"
        "- ABAC\n\n"
        "based on current business requirements."
    )

    st.divider()

    st.subheader("4. Attribute Mapping")
    if df_mapping.empty:
        st.info("No attribute mappings found.")
    else:
        active_map = df_mapping[df_mapping["ACTIVE_FLAG"] == "Y"].copy()
        st.metric("Active Mappings", len(active_map))

        col_a, col_b = st.columns(2)
        with col_a:
            src_counts = active_map["SOURCE_SYSTEM"].value_counts().reset_index()
            src_counts.columns = ["SOURCE_SYSTEM", "COUNT"]
            chart = alt.Chart(src_counts).mark_bar(cornerRadiusEnd=4).encode(
                y=alt.Y("SOURCE_SYSTEM:N", sort="-x", title="Source System"),
                x=alt.X("COUNT:Q", title="Mapping Count"),
                color=alt.Color("SOURCE_SYSTEM:N", legend=None),
                tooltip=["SOURCE_SYSTEM", "COUNT"]
            ).properties(title="Mappings By Source System", height=250).interactive()
            st.altair_chart(chart, use_container_width=True)

        with col_b:
            attr_counts = active_map["CANONICAL_ATTRIBUTE"].value_counts().reset_index()
            attr_counts.columns = ["CANONICAL_ATTRIBUTE", "COUNT"]
            chart = alt.Chart(attr_counts).mark_bar(cornerRadiusEnd=4).encode(
                y=alt.Y("CANONICAL_ATTRIBUTE:N", sort="-x", title="Canonical Attribute"),
                x=alt.X("COUNT:Q", title="Source Count"),
                color=alt.Color("CANONICAL_ATTRIBUTE:N", legend=None),
                tooltip=["CANONICAL_ATTRIBUTE", "COUNT"]
            ).properties(title="Mappings By Canonical Attribute", height=250).interactive()
            st.altair_chart(chart, use_container_width=True)

        with st.expander("Attribute Mapping Table"):
            st.dataframe(active_map.sort_values(["CANONICAL_ATTRIBUTE", "SOURCE_SYSTEM"]),
                         use_container_width=True, hide_index=True)

with tab6:
    st.header("MDM Architecture")
    st.caption("Complete solution architecture — P1 through P15 — for the Relationship Discovery MDM Framework.")

    st.subheader("Full Processing Pipeline (P1 – P15)")
    st.markdown("""
```
 P1  Database & Schema Setup
 P2  Source Tables (ERP, Supplier, Inventory, Ecommerce)
 P3  Source Test Data Generation
 P4  Metadata Tables (DQ Rules, Survivorship, Attribute Mapping)
      |
      v
 P5  SOURCE_SUPERSET (Harmonize all sources into canonical model)
      |
      v
 P6  DQ_RESULTS + DQ_RECORD_SUMMARY (Score every record)
      |
      v
 P7  RELATIONSHIP_CANDIDATES (Pairwise matching: T0, T1, T2)
      |
      v
 P8  RELATIONSHIP_CATALOG (Best-match selection per entity)
      |
      v
 P9  INTM_PRODUCT_MASTER Framework (DDL + ACTION_LOG DDL)
      |
      v
 P10 Generate Master Candidate CREATE Actions (BR)
     - Entity Resolution via Connected Components
     - Survivorship (metadata-driven)
     - Golden Key: BRAND | PRODUCT_NAME | SIZE
     - Writes CREATE actions to ACTION_LOG
      |
      v
 P11 DAL – Apply ACTION_LOG to INTM_PRODUCT_MASTER
     - Process CREATE / UPDATE / DELETE
     - Version history, soft deletes
     - State validation before marking COMPLETED
      |
      v
 P12 Derive PRODUCT_FAMILY from CATEGORY (BR -> UPDATE actions)
      |
      v
 P11 DAL (re-run)
      |
      v
 P13 Derive PRODUCT_GROUP from PRODUCT_FAMILY (BR -> UPDATE actions)
      |
      v
 P11 DAL (re-run)
      |
      v
 P14 Derive PRODUCT_STATUS from PRODUCT_GROUP (BR -> UPDATE actions)
      |
      v
 P11 DAL (re-run)
      |
      v
 P15 Publish FINAL.PRODUCT_MASTER (Active records only)
      |
      v
 P16 Security Layer
     - RBAC (4 roles: MDM_ADMIN, MDM_DATA_STEWARD,
       MDM_BUSINESS_USER, MDM_AUDITOR)
     - Dynamic Masking (SALE_PRICE,
       SOURCE_EXECUTION_REFERENCE, ACTION_SOURCE)
      |
      v
 Dashboard
```
    """)

    st.divider()

    col_a, col_b = st.columns(2)

    with col_a:
        st.subheader("Layer Breakdown")
        st.markdown("""
| Layer | Prompts | Purpose |
|-------|---------|---------|
| **Platform** | P1 | Database, schemas, roles |
| **Source** | P2, P3 | 4 source systems, test data |
| **Metadata** | P4 | DQ rules, survivorship, mappings |
| **Intermediate** | P5–P9 | Harmonization, DQ, relationship discovery |
| **Business Rules** | P10, P12–P14 | Entity resolution, derivations |
| **DAL** | P11 | State materialization (reusable) |
| **Final** | P15 | Golden record publication |
| **Security** | P16 | RBAC + Dynamic Masking |
        """)

    with col_b:
        st.subheader("Derivation Hierarchy")
        st.markdown("""
```
CATEGORY (source attribute)
    |
    v
DERIVED_PRODUCT_FAMILY (P12)
  CHEMICALS, FOOD, PERSONAL_HEALTH,
  AUTOMOTIVE, HOME, OFFICE,
  ELECTRONICS, INDUSTRIAL, CONSUMER,
  SPECIALTY, OTHER
    |
    v
DERIVED_PRODUCT_GROUP (P13)
  STORE_OPERATIONS, CONSUMER_PRODUCTS,
  HEALTH_BEAUTY, LIFESTYLE,
  BUSINESS_PRODUCTS, SPECIALTY, OTHER
    |
    v
DERIVED_PRODUCT_STATUS (P14)
  ACTIVE, REVIEW
```
        """)

    st.divider()

    st.subheader("Key Architecture Principles")
    c1, c2, c3 = st.columns(3)

    with c1:
        st.markdown("**Separation of Concerns**")
        st.markdown("""
- Business Rules generate actions
- DAL applies actions to state
- BRs never update master directly
- DAL never makes business decisions
- Each prompt = one artifact
        """)

    with c2:
        st.markdown("**Version History & Lineage**")
        st.markdown("""
- Every change creates a new version
- No physical deletions
- Full audit trail via ACTION_SOURCE
- Traceable from source to golden record
- P1-P9 builds foundation, P10-P15 masters
        """)

    with c3:
        st.markdown("**Metadata-Driven**")
        st.markdown("""
- DQ rules from MD_ATTRIBUTE_DQ_RULES
- Survivorship from MD_ATTRIBUTE_SURVIVORSHIP
- Mappings from MD_ATTRIBUTE_MAPPING
- Transformations: T0, T1, T2 (hardcoded)
- Golden Key: BRAND|PRODUCT_NAME|SIZE
        """)
