import streamlit as st
import altair as alt
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Relationship Discovery Framework", layout="wide")
session = get_active_session()

st.markdown("""
<style>
    .main .block-container { padding-top: 1.2rem; max-width: 100%; }

    [data-testid="stMetric"] {
        background: linear-gradient(135deg, #1e1b4b08, #4f46e508);
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 18px 22px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.03);
    }
    [data-testid="stMetricLabel"] {
        font-size: 0.75rem !important;
        font-weight: 600 !important;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: #64748b !important;
    }
    [data-testid="stMetricValue"] {
        font-size: 1.9rem !important;
        font-weight: 700 !important;
        color: #1e293b !important;
    }

    .stTabs [data-baseweb="tab-list"] {
        gap: 0; background: #f8fafc; border-radius: 14px; padding: 5px; border: 1px solid #e2e8f0;
    }
    .stTabs [data-baseweb="tab"] {
        border-radius: 10px; padding: 10px 22px; font-weight: 500; font-size: 0.84rem; color: #64748b;
    }
    .stTabs [aria-selected="true"] {
        background: white !important; color: #4f46e5 !important; font-weight: 700 !important;
        box-shadow: 0 2px 10px rgba(79, 70, 229, 0.12);
    }

    .hero { text-align: center; padding: 1rem 0 0.5rem; }
    .hero h1 {
        font-size: 2.4rem; font-weight: 800;
        background: linear-gradient(135deg, #4f46e5, #7c3aed, #ec4899);
        -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        margin-bottom: 0;
    }
    .hero p { color: #64748b; font-size: 1rem; margin-top: 6px; }

    .callout {
        border-radius: 12px; padding: 16px 20px; margin: 12px 0;
        font-size: 0.88rem; line-height: 1.5;
    }
    .callout-blue { background: #eff6ff; border-left: 4px solid #3b82f6; }
    .callout-purple { background: #faf5ff; border-left: 4px solid #7c3aed; }
    .callout-green { background: #f0fdf4; border-left: 4px solid #10b981; }
    .callout-amber { background: #fffbeb; border-left: 4px solid #f59e0b; }

    .section-title {
        font-size: 1.05rem; font-weight: 700; color: #1e293b;
        margin: 20px 0 8px; padding-bottom: 6px; border-bottom: 2px solid #4f46e510;
    }

    .pipeline-step {
        text-align: center; padding: 14px 10px; border-radius: 12px;
        border: 1px solid #e2e8f0; background: white;
    }
    .pipeline-step .number { font-size: 1.6rem; font-weight: 800; color: #4f46e5; }
    .pipeline-step .label { font-size: 0.75rem; color: #64748b; margin-top: 2px; }
</style>
""", unsafe_allow_html=True)

st.markdown("""
<div class="hero">
    <h1>Relationship Discovery Framework</h1>
    <p>Intelligent Entity Resolution — Transforming 42,450 fragmented records into 5,567 golden products</p>
</div>
""", unsafe_allow_html=True)

C = {
    "indigo": "#4f46e5", "violet": "#7c3aed", "emerald": "#10b981",
    "amber": "#f59e0b", "rose": "#f43f5e", "sky": "#0ea5e9",
    "slate": "#475569", "systems": ["#4f46e5", "#7c3aed", "#0ea5e9", "#f97316"],
}


@st.cache_data(ttl=600)
def q(sql):
    return session.sql(sql).to_pandas()


tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs([
    "The Story", "Live Explorer", "Discovery Engine", "Data Quality", "Golden Master", "Architecture"
])

# ═══════════════════════════════════════════════════════════════════
# TAB 1: THE STORY - Executive Narrative
# ═══════════════════════════════════════════════════════════════════
with tab1:

    st.markdown("""
    <div class="callout callout-purple">
        <strong>The Problem:</strong> Enterprises maintain product data across multiple disconnected systems — ERP, Supplier portals,
        Inventory systems, and Ecommerce platforms. The same product exists with different names, codes, and attributes in each.
        Without intelligent resolution, data duplication costs millions in operational waste.
    </div>
    """, unsafe_allow_html=True)

    st.markdown('<p class="section-title">The Pipeline</p>', unsafe_allow_html=True)
    p1, p2, p3, p4, p5 = st.columns(5)
    with p1:
        st.markdown('<div class="pipeline-step"><div class="number">42,450</div><div class="label">SOURCE RECORDS<br/>4 Systems</div></div>', unsafe_allow_html=True)
    with p2:
        st.markdown('<div class="pipeline-step"><div class="number">21.8M</div><div class="label">CANDIDATES<br/>Pairs Evaluated</div></div>', unsafe_allow_html=True)
    with p3:
        st.markdown('<div class="pipeline-step"><div class="number">30,000</div><div class="label">CATALOGED<br/>Best Matches</div></div>', unsafe_allow_html=True)
    with p4:
        st.markdown('<div class="pipeline-step"><div class="number">5,567</div><div class="label">GOLDEN RECORDS<br/>Unique Products</div></div>', unsafe_allow_html=True)
    with p5:
        st.markdown('<div class="pipeline-step"><div class="number">86.9%</div><div class="label">DEDUPLICATION<br/>Rate Achieved</div></div>', unsafe_allow_html=True)

    st.markdown("")
    st.markdown("")

    col_l, col_r = st.columns([3, 2])

    with col_l:
        st.markdown('<p class="section-title">Consolidation Power</p>', unsafe_allow_html=True)
        funnel_data = pd.DataFrame([
            {"Stage": "1. Source Ingestion", "Records": 42450, "Description": "4 systems harmonized"},
            {"Stage": "2. Candidate Pairs", "Records": 21797578, "Description": "Pairwise discovery"},
            {"Stage": "3. Cataloged Matches", "Records": 30000, "Description": "Best-match per entity"},
            {"Stage": "4. Golden Records", "Records": 5567, "Description": "Final mastered products"},
        ])
        chart = alt.Chart(funnel_data).mark_bar(cornerRadiusTopRight=8, cornerRadiusBottomRight=8).encode(
            y=alt.Y("Stage:N", sort=None, title=None, axis=alt.Axis(labelFontSize=12, labelFontWeight="bold")),
            x=alt.X("Records:Q", title="Record Count (Log Scale)", scale=alt.Scale(type="log")),
            color=alt.Color("Stage:N", legend=None,
                           scale=alt.Scale(range=[C["sky"], C["violet"], C["indigo"], C["emerald"]])),
            tooltip=["Stage", alt.Tooltip("Records:Q", format=","), "Description"]
        ).properties(height=220)
        st.altair_chart(chart, use_container_width=True)

    with col_r:
        st.markdown('<p class="section-title">Source Systems</p>', unsafe_allow_html=True)
        src_data = pd.DataFrame([
            {"System": "ERP", "Records": 10250, "Brands": 35},
            {"System": "Supplier", "Records": 10800, "Brands": 33},
            {"System": "Inventory", "Records": 10450, "Brands": 53},
            {"System": "Ecommerce", "Records": 10950, "Brands": 33},
        ])
        chart = alt.Chart(src_data).mark_bar(cornerRadiusTopLeft=8, cornerRadiusTopRight=8).encode(
            x=alt.X("System:N", title=None, axis=alt.Axis(labelAngle=0)),
            y=alt.Y("Records:Q", title="Records"),
            color=alt.Color("System:N", legend=None, scale=alt.Scale(range=C["systems"])),
            tooltip=["System", "Records", "Brands"]
        ).properties(height=220)
        st.altair_chart(chart, use_container_width=True)

    st.divider()

    st.markdown('<p class="section-title">What Makes This Different</p>', unsafe_allow_html=True)
    d1, d2, d3 = st.columns(3)
    with d1:
        st.markdown("""
        <div class="callout callout-blue">
            <strong>Multi-Tier Matching</strong><br/>
            T0 (Exact) → T1 (Fuzzy) → T2 (Prefix)<br/>
            Each tier has calibrated scoring and confidence levels.
        </div>
        """, unsafe_allow_html=True)
    with d2:
        st.markdown("""
        <div class="callout callout-green">
            <strong>DQ-Weighted Discovery</strong><br/>
            Relationship scores are weighted by data quality.<br/>
            Higher quality sources win survivorship battles.
        </div>
        """, unsafe_allow_html=True)
    with d3:
        st.markdown("""
        <div class="callout callout-amber">
            <strong>Metadata-Driven</strong><br/>
            DQ rules, survivorship priority, and mappings<br/>
            are all configurable without code changes.
        </div>
        """, unsafe_allow_html=True)

    st.divider()
    st.markdown('<p class="section-title">Key Results</p>', unsafe_allow_html=True)
    r1, r2, r3, r4, r5 = st.columns(5)
    r1.metric("Consolidation", "7.6 : 1")
    r2.metric("Precision Filter", "99.86%")
    r3.metric("DQ Pass Rate", "98.9%")
    r4.metric("Cross-System Links", "6 pairs")
    r5.metric("Versions Tracked", "22,268")


# ═══════════════════════════════════════════════════════════════════
# TAB 2: LIVE EXPLORER - Interactive Demo
# ═══════════════════════════════════════════════════════════════════
with tab2:

    explorer_mode = st.radio(
        "Choose exploration mode:",
        ["Before / After — Source vs Golden", "Entity Deep Dive", "Relationship Lookup"],
        horizontal=True
    )

    st.divider()

    if explorer_mode == "Before / After — Source vs Golden":

        st.markdown("""
        <div class="callout callout-purple">
            <strong>Before / After:</strong> See how the same product appears differently across 4 source systems,
            and how the framework resolves it into a single golden record with survivorship-driven attribute selection.
        </div>
        """, unsafe_allow_html=True)

        df_golden_sample = q("""
            SELECT ENTITY_KEY, BRAND, PRODUCT_NAME, SIZE, DERIVED_PRODUCT_FAMILY,
                   ERP_PRODUCT_ID, SUPPLIER_PRODUCT_ID, INVENTORY_PRODUCT_ID, ECOMMERCE_PRODUCT_ID
            FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER
            WHERE ERP_PRODUCT_ID IS NOT NULL OR SUPPLIER_PRODUCT_ID IS NOT NULL
            ORDER BY BRAND, PRODUCT_NAME
        """)

        display_options = (df_golden_sample["BRAND"] + " — " + df_golden_sample["PRODUCT_NAME"] + " (" + df_golden_sample["SIZE"].fillna("") + ")").tolist()
        selected_idx = st.selectbox("Select a Golden Record:", range(len(display_options)),
                                    format_func=lambda i: display_options[i], index=0)

        selected_row = df_golden_sample.iloc[selected_idx]
        entity_key = selected_row["ENTITY_KEY"]

        source_ids = []
        if pd.notna(selected_row.get("ERP_PRODUCT_ID")):
            source_ids.append(f"(SOURCE_SYSTEM='ERP_PRODUCT' AND SOURCE_RECORD_ID='{selected_row['ERP_PRODUCT_ID']}')")
        if pd.notna(selected_row.get("SUPPLIER_PRODUCT_ID")):
            source_ids.append(f"(SOURCE_SYSTEM='SUPPLIER_PRODUCT' AND SOURCE_RECORD_ID='{selected_row['SUPPLIER_PRODUCT_ID']}')")
        if pd.notna(selected_row.get("INVENTORY_PRODUCT_ID")):
            source_ids.append(f"(SOURCE_SYSTEM='INVENTORY_PRODUCT' AND SOURCE_RECORD_ID='{selected_row['INVENTORY_PRODUCT_ID']}')")
        if pd.notna(selected_row.get("ECOMMERCE_PRODUCT_ID")):
            source_ids.append(f"(SOURCE_SYSTEM='ECOMMERCE_PRODUCT' AND SOURCE_RECORD_ID='{selected_row['ECOMMERCE_PRODUCT_ID']}')")

        if source_ids:
            where_clause = " OR ".join(source_ids)
            df_sources = q(f"""
                SELECT SOURCE_SYSTEM, SOURCE_RECORD_ID, BRAND, PRODUCT_NAME, CATEGORY, MANUFACTURER, SIZE
                FROM RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET
                WHERE {where_clause}
                ORDER BY SOURCE_SYSTEM
            """)

            st.markdown("")
            st.markdown('<p class="section-title">BEFORE — Raw Source Records</p>', unsafe_allow_html=True)

            if not df_sources.empty:
                df_display = df_sources.copy()
                df_display["SOURCE_SYSTEM"] = df_display["SOURCE_SYSTEM"].str.replace("_PRODUCT", "")
                st.dataframe(df_display, use_container_width=True, hide_index=True)

                st.markdown("")
                attrs = ["BRAND", "PRODUCT_NAME", "CATEGORY", "MANUFACTURER", "SIZE"]
                diff_data = []
                for attr in attrs:
                    vals = df_sources[attr].dropna().unique()
                    diff_data.append({
                        "Attribute": attr,
                        "Unique Values Across Sources": len(vals),
                        "Variations": " | ".join(str(v) for v in vals[:4]),
                        "Conflict": "Yes" if len(vals) > 1 else "No"
                    })
                df_diff = pd.DataFrame(diff_data)
                conflict_count = int(df_diff["Conflict"].eq("Yes").sum())
                st.caption(f"Attribute conflicts detected: **{conflict_count}** of {len(attrs)} — resolved by survivorship")

            st.markdown("")
            st.markdown('<p class="section-title">AFTER — Golden Record (Resolved)</p>', unsafe_allow_html=True)

            golden_display = pd.DataFrame([{
                "ENTITY_KEY": entity_key[:16] + "...",
                "BRAND": selected_row["BRAND"],
                "PRODUCT_NAME": selected_row["PRODUCT_NAME"],
                "SIZE": selected_row["SIZE"],
                "PRODUCT_FAMILY": selected_row["DERIVED_PRODUCT_FAMILY"],
                "Sources Merged": sum([
                    pd.notna(selected_row.get("ERP_PRODUCT_ID")),
                    pd.notna(selected_row.get("SUPPLIER_PRODUCT_ID")),
                    pd.notna(selected_row.get("INVENTORY_PRODUCT_ID")),
                    pd.notna(selected_row.get("ECOMMERCE_PRODUCT_ID")),
                ])
            }])
            st.dataframe(golden_display, use_container_width=True, hide_index=True)

            st.markdown("""
            <div class="callout callout-green" style="margin-top:12px;">
                <strong>Resolution Logic:</strong> ERP wins BRAND/PRODUCT_NAME (priority 1),
                variations in CATEGORY/MANUFACTURER/SIZE are resolved by source trust ranking.
                The golden key (BRAND|PRODUCT_NAME|SIZE) ensures uniqueness.
            </div>
            """, unsafe_allow_html=True)
        else:
            st.info("No linked source records found for this entity.")

    elif explorer_mode == "Entity Deep Dive":

        st.markdown("""
        <div class="callout callout-blue">
            <strong>Entity Deep Dive:</strong> Explore any golden entity's complete lifecycle —
            version history, action audit trail, and all enrichment phases applied.
        </div>
        """, unsafe_allow_html=True)

        df_entities = q("""
            SELECT ENTITY_KEY, BRAND, PRODUCT_NAME, SIZE, DERIVED_PRODUCT_STATUS
            FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER
            ORDER BY BRAND, PRODUCT_NAME
        """)

        entity_labels = (df_entities["BRAND"] + " — " + df_entities["PRODUCT_NAME"]).tolist()
        sel_idx = st.selectbox("Select Entity:", range(len(entity_labels)),
                              format_func=lambda i: entity_labels[i], index=0)
        sel_entity = df_entities.iloc[sel_idx]["ENTITY_KEY"]

        df_versions = q(f"""
            SELECT VERSION_NO, ACTIVE_FLAG, ACTION_SOURCE, BRAND, PRODUCT_NAME,
                   DERIVED_PRODUCT_FAMILY, DERIVED_PRODUCT_GROUP, DERIVED_PRODUCT_STATUS,
                   CREATED_DTTM
            FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
            WHERE ENTITY_KEY = '{sel_entity}'
            ORDER BY VERSION_NO
        """)

        if not df_versions.empty:
            v1, v2, v3 = st.columns(3)
            v1.metric("Total Versions", len(df_versions))
            v2.metric("Current Status", df_entities.iloc[sel_idx]["DERIVED_PRODUCT_STATUS"])
            active_ver = df_versions[df_versions["ACTIVE_FLAG"] == "Y"]
            v3.metric("Active Version", int(active_ver["VERSION_NO"].iloc[0]) if not active_ver.empty else "N/A")

            st.markdown('<p class="section-title">Version Timeline</p>', unsafe_allow_html=True)

            timeline = df_versions.copy()
            timeline["VERSION_NO"] = timeline["VERSION_NO"].astype(int)
            timeline["PHASE"] = timeline["ACTION_SOURCE"].fillna("P10_CREATION")
            timeline["PHASE"] = timeline["PHASE"].replace("***MASKED***", "P10_CREATION")

            chart = alt.Chart(timeline).mark_circle(size=300).encode(
                x=alt.X("VERSION_NO:O", title="Version"),
                y=alt.Y("PHASE:N", title=None),
                color=alt.Color("PHASE:N", title="Processing Phase",
                               scale=alt.Scale(scheme="category10")),
                size=alt.condition(alt.datum.ACTIVE_FLAG == "Y", alt.value(500), alt.value(200)),
                tooltip=["VERSION_NO", "PHASE", "ACTIVE_FLAG", "BRAND", "PRODUCT_NAME",
                         "DERIVED_PRODUCT_FAMILY", "DERIVED_PRODUCT_GROUP", "DERIVED_PRODUCT_STATUS"]
            ).properties(height=200).interactive()
            st.altair_chart(chart, use_container_width=True)

            st.markdown('<p class="section-title">Full Version History</p>', unsafe_allow_html=True)
            st.dataframe(df_versions, use_container_width=True, hide_index=True)
        else:
            st.warning("No version history found for this entity.")

    elif explorer_mode == "Relationship Lookup":

        st.markdown("""
        <div class="callout callout-amber">
            <strong>Relationship Lookup:</strong> Pick any source record and see all relationships
            discovered by the engine — which systems matched, at what confidence, and with what DQ backing.
        </div>
        """, unsafe_allow_html=True)

        source_system = st.selectbox("Source System:", ["ERP_PRODUCT", "SUPPLIER_PRODUCT", "INVENTORY_PRODUCT", "ECOMMERCE_PRODUCT"])

        sample_records = q(f"""
            SELECT SOURCE_RECORD_ID, BRAND, PRODUCT_NAME, SIZE
            FROM RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET
            WHERE SOURCE_SYSTEM = '{source_system}'
            ORDER BY BRAND, PRODUCT_NAME
            LIMIT 500
        """)

        record_labels = (sample_records["BRAND"].fillna("") + " — " + sample_records["PRODUCT_NAME"].fillna("") + " [ID:" + sample_records["SOURCE_RECORD_ID"] + "]").tolist()
        sel_rec_idx = st.selectbox("Select Record:", range(len(record_labels)),
                                   format_func=lambda i: record_labels[i], index=0)
        sel_record_id = sample_records.iloc[sel_rec_idx]["SOURCE_RECORD_ID"]

        df_rels = q(f"""
            SELECT LEFT_SOURCE_SYSTEM, LEFT_SOURCE_RECORD_ID,
                   RIGHT_SOURCE_SYSTEM, RIGHT_SOURCE_RECORD_ID,
                   MATCH_TYPE, MATCH_SCORE, MATCH_CONFIDENCE, DQ_WEIGHTED_SCORE
            FROM RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG
            WHERE (LEFT_SOURCE_SYSTEM = '{source_system}' AND LEFT_SOURCE_RECORD_ID = '{sel_record_id}')
               OR (RIGHT_SOURCE_SYSTEM = '{source_system}' AND RIGHT_SOURCE_RECORD_ID = '{sel_record_id}')
            ORDER BY MATCH_SCORE DESC
        """)

        if not df_rels.empty:
            r1, r2, r3 = st.columns(3)
            r1.metric("Relationships Found", len(df_rels))
            r2.metric("Best Match Score", int(df_rels["MATCH_SCORE"].max()))
            r3.metric("Avg DQ Backing", f"{df_rels['DQ_WEIGHTED_SCORE'].mean():.1f}")

            st.markdown('<p class="section-title">Discovered Relationships</p>', unsafe_allow_html=True)

            df_rels_display = df_rels.copy()
            df_rels_display["LEFT"] = df_rels_display["LEFT_SOURCE_SYSTEM"].str.replace("_PRODUCT", "") + " #" + df_rels_display["LEFT_SOURCE_RECORD_ID"]
            df_rels_display["RIGHT"] = df_rels_display["RIGHT_SOURCE_SYSTEM"].str.replace("_PRODUCT", "") + " #" + df_rels_display["RIGHT_SOURCE_RECORD_ID"]

            chart = alt.Chart(df_rels_display).mark_bar(cornerRadiusTopLeft=6, cornerRadiusTopRight=6).encode(
                y=alt.Y("RIGHT:N", sort="-x", title=None) if df_rels_display["LEFT_SOURCE_SYSTEM"].iloc[0] == source_system
                  else alt.Y("LEFT:N", sort="-x", title=None),
                x=alt.X("MATCH_SCORE:Q", title="Match Score", scale=alt.Scale(domain=[0, 105])),
                color=alt.Color("MATCH_CONFIDENCE:N", title="Confidence",
                               scale=alt.Scale(domain=["HIGH", "MEDIUM", "LOW"],
                                              range=[C["emerald"], C["amber"], C["rose"]])),
                tooltip=["LEFT_SOURCE_SYSTEM", "LEFT_SOURCE_RECORD_ID",
                         "RIGHT_SOURCE_SYSTEM", "RIGHT_SOURCE_RECORD_ID",
                         "MATCH_TYPE", "MATCH_SCORE", "MATCH_CONFIDENCE",
                         alt.Tooltip("DQ_WEIGHTED_SCORE:Q", format=".1f")]
            ).properties(height=max(len(df_rels) * 40, 150))
            st.altair_chart(chart, use_container_width=True)

            st.markdown('<p class="section-title">Relationship Details</p>', unsafe_allow_html=True)
            st.dataframe(df_rels[["LEFT_SOURCE_SYSTEM", "LEFT_SOURCE_RECORD_ID",
                                  "RIGHT_SOURCE_SYSTEM", "RIGHT_SOURCE_RECORD_ID",
                                  "MATCH_TYPE", "MATCH_SCORE", "MATCH_CONFIDENCE", "DQ_WEIGHTED_SCORE"]],
                        use_container_width=True, hide_index=True)
        else:
            st.info("No cataloged relationships found for this record. It may be a standalone entity or matched via a different record as the 'left' side.")


# ═══════════════════════════════════════════════════════════════════
# TAB 3: DISCOVERY ENGINE
# ═══════════════════════════════════════════════════════════════════
with tab3:

    st.markdown("""
    <div class="callout callout-purple">
        <strong>Core Innovation:</strong> The engine performs pairwise comparison across all source systems using blocking
        (first-3-character match) to reduce the search space, then applies T0/T1/T2 transformation matching with
        DQ-weighted scoring to identify the single best relationship for each entity.
    </div>
    """, unsafe_allow_html=True)

    with st.spinner("Loading discovery data..."):
        df_catalog = q("""
            SELECT LEFT_SOURCE_SYSTEM, RIGHT_SOURCE_SYSTEM,
                   MATCH_TYPE, MATCH_SCORE, MATCH_CONFIDENCE, DQ_WEIGHTED_SCORE
            FROM RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG
        """)
        df_cand_summary = q("""
            SELECT MATCH_TYPE, MATCH_CONFIDENCE, COUNT(*) AS CNT,
                   ROUND(AVG(MATCH_SCORE),1) AS AVG_SCORE, ROUND(AVG(DQ_WEIGHTED_SCORE),1) AS AVG_DQ
            FROM RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES
            GROUP BY MATCH_TYPE, MATCH_CONFIDENCE
        """)

    m1, m2, m3, m4 = st.columns(4)
    m1.metric("Candidates Generated", "21.8M")
    m2.metric("Cataloged (Best)", f"{len(df_catalog):,}")
    m3.metric("Reduction", "99.86%")
    m4.metric("Avg DQ Score", f"{df_catalog['DQ_WEIGHTED_SCORE'].mean():.1f}")

    st.divider()

    col_l, col_r = st.columns(2)

    with col_l:
        st.markdown('<p class="section-title">Match Confidence Tiers</p>', unsafe_allow_html=True)
        tier_data = df_catalog.groupby(["MATCH_TYPE", "MATCH_CONFIDENCE"]).agg(
            COUNT=("MATCH_SCORE", "count"),
            AVG_SCORE=("MATCH_SCORE", "mean"),
            AVG_DQ=("DQ_WEIGHTED_SCORE", "mean")
        ).reset_index()

        chart = alt.Chart(tier_data).mark_bar(cornerRadiusTopLeft=8, cornerRadiusTopRight=8).encode(
            x=alt.X("MATCH_TYPE:N", title=None,
                    axis=alt.Axis(labelExpr="datum.value == 'T0' ? 'T0 — Exact' : datum.value == 'T1' ? 'T1 — Fuzzy' : 'T2 — Prefix'")),
            y=alt.Y("COUNT:Q", title="Relationships"),
            color=alt.Color("MATCH_CONFIDENCE:N", title="Confidence",
                           scale=alt.Scale(domain=["HIGH", "MEDIUM", "LOW"],
                                          range=[C["emerald"], C["amber"], C["rose"]])),
            tooltip=["MATCH_TYPE", "MATCH_CONFIDENCE", "COUNT",
                     alt.Tooltip("AVG_SCORE:Q", format=".0f", title="Avg Score"),
                     alt.Tooltip("AVG_DQ:Q", format=".1f", title="Avg DQ")]
        ).properties(height=320)
        st.altair_chart(chart, use_container_width=True)

    with col_r:
        st.markdown('<p class="section-title">Cross-System Relationship Density</p>', unsafe_allow_html=True)
        pairs = df_catalog.groupby(["LEFT_SOURCE_SYSTEM", "RIGHT_SOURCE_SYSTEM"]).agg(
            COUNT=("MATCH_SCORE", "count"),
            AVG_SCORE=("MATCH_SCORE", "mean")
        ).reset_index()
        pairs["LEFT"] = pairs["LEFT_SOURCE_SYSTEM"].str.replace("_PRODUCT", "")
        pairs["RIGHT"] = pairs["RIGHT_SOURCE_SYSTEM"].str.replace("_PRODUCT", "")

        base = alt.Chart(pairs).mark_rect(cornerRadius=8).encode(
            x=alt.X("LEFT:N", title=None),
            y=alt.Y("RIGHT:N", title=None),
            color=alt.Color("COUNT:Q", scale=alt.Scale(scheme="purples"), title="Relationships"),
            tooltip=["LEFT_SOURCE_SYSTEM", "RIGHT_SOURCE_SYSTEM", "COUNT",
                     alt.Tooltip("AVG_SCORE:Q", format=".0f", title="Avg Score")]
        ).properties(height=320)

        text = alt.Chart(pairs).mark_text(fontSize=16, fontWeight="bold", color="white").encode(
            x="LEFT:N", y="RIGHT:N", text=alt.Text("COUNT:Q", format=",")
        )
        st.altair_chart(base + text, use_container_width=True)

    st.divider()

    st.markdown('<p class="section-title">Candidates vs Catalog — Selectivity by Tier</p>', unsafe_allow_html=True)
    catalog_summary = df_catalog.groupby("MATCH_TYPE").size().reset_index(name="CATALOGED")
    df_cand_summary_agg = df_cand_summary.groupby("MATCH_TYPE")["CNT"].sum().reset_index()
    df_cand_summary_agg.columns = ["MATCH_TYPE", "CANDIDATES"]
    compare = catalog_summary.merge(df_cand_summary_agg, on="MATCH_TYPE")
    compare["SELECTIVITY"] = (compare["CATALOGED"] / compare["CANDIDATES"] * 100).round(3)
    compare["LABEL"] = compare.apply(
        lambda r: f"T0 — Exact Match" if r["MATCH_TYPE"] == "T0"
        else f"T1 — Fuzzy Match" if r["MATCH_TYPE"] == "T1"
        else "T2 — Prefix Match", axis=1)

    col_t1, col_t2, col_t3 = st.columns(3)
    for i, (col, row) in enumerate(zip([col_t1, col_t2, col_t3], compare.itertuples())):
        with col:
            col.metric(row.LABEL, f"{row.CATALOGED:,} selected")
            col.caption(f"From {row.CANDIDATES:,} candidates ({row.SELECTIVITY}% selectivity)")


# ═══════════════════════════════════════════════════════════════════
# TAB 4: DATA QUALITY
# ═══════════════════════════════════════════════════════════════════
with tab4:

    st.markdown("""
    <div class="callout callout-green">
        <strong>DQ-First Design:</strong> Every source record is scored against metadata-driven rules before
        entering relationship discovery. DQ scores directly weight match quality — ensuring high-quality
        data wins survivorship and poor data is flagged, never silently propagated.
    </div>
    """, unsafe_allow_html=True)

    with st.spinner("Loading DQ data..."):
        df_dq = q("""
            SELECT SOURCE_SYSTEM, RECORD_DQ_STATUS, RECORD_DQ_SCORE, FAILED_ATTRIBUTES
            FROM RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY
        """)

    total_assessed = len(df_dq)
    pass_count = int((df_dq["RECORD_DQ_STATUS"] == "PASS").sum())
    warn_count = int((df_dq["RECORD_DQ_STATUS"] == "WARNING").sum())
    avg_score = round(df_dq["RECORD_DQ_SCORE"].mean(), 1)
    pass_rate = round(pass_count / total_assessed * 100, 1)

    m1, m2, m3, m4 = st.columns(4)
    m1.metric("Records Assessed", f"{total_assessed:,}")
    m2.metric("Avg DQ Score", f"{avg_score}")
    m3.metric("Pass Rate (≥80)", f"{pass_rate}%")
    m4.metric("Warnings", f"{warn_count:,}")

    st.divider()

    col_l, col_r = st.columns(2)

    with col_l:
        st.markdown('<p class="section-title">DQ Status by Source System</p>', unsafe_allow_html=True)
        dq_status = df_dq.groupby(["SOURCE_SYSTEM", "RECORD_DQ_STATUS"]).size().reset_index(name="COUNT")
        dq_status["SYSTEM"] = dq_status["SOURCE_SYSTEM"].str.replace("_PRODUCT", "")

        chart = alt.Chart(dq_status).mark_bar(cornerRadiusTopLeft=6, cornerRadiusTopRight=6).encode(
            x=alt.X("SYSTEM:N", title=None, axis=alt.Axis(labelAngle=0)),
            y=alt.Y("COUNT:Q", title="Records", stack="zero"),
            color=alt.Color("RECORD_DQ_STATUS:N", title="Status",
                           scale=alt.Scale(domain=["PASS", "WARNING"],
                                          range=[C["emerald"], C["amber"]])),
            tooltip=["SOURCE_SYSTEM", "RECORD_DQ_STATUS", "COUNT"]
        ).properties(height=300)
        st.altair_chart(chart, use_container_width=True)

    with col_r:
        st.markdown('<p class="section-title">Score Distribution</p>', unsafe_allow_html=True)
        chart = alt.Chart(df_dq).mark_bar(cornerRadiusTopLeft=4, cornerRadiusTopRight=4).encode(
            x=alt.X("RECORD_DQ_SCORE:Q", bin=alt.Bin(step=5), title="DQ Score"),
            y=alt.Y("count():Q", title="Records"),
            color=alt.value(C["indigo"]),
            tooltip=[alt.Tooltip("RECORD_DQ_SCORE:Q", bin=alt.Bin(step=5), title="Range"), "count()"]
        ).properties(height=300)
        st.altair_chart(chart, use_container_width=True)

    st.divider()

    st.markdown('<p class="section-title">DQ Rules Framework</p>', unsafe_allow_html=True)

    col_rules, col_impact = st.columns([3, 2])
    with col_rules:
        rules_df = pd.DataFrame([
            {"Attribute": "BRAND", "Critical": "Yes", "Rule": "NOT_NULL", "Impact": "Record scores 0 if null"},
            {"Attribute": "PRODUCT_NAME", "Critical": "Yes", "Rule": "NOT_NULL", "Impact": "Record scores 0 if null"},
            {"Attribute": "SIZE", "Critical": "Yes", "Rule": "NOT_NULL", "Impact": "Record scores 0 if null"},
            {"Attribute": "CATEGORY", "Critical": "No", "Rule": "COMPLETENESS", "Impact": "Score reduced to 50"},
            {"Attribute": "MANUFACTURER", "Critical": "No", "Rule": "COMPLETENESS", "Impact": "Score reduced to 50"},
            {"Attribute": "SALE_PRICE", "Critical": "No", "Rule": "COMPLETENESS", "Impact": "Score reduced to 50"},
        ])
        st.dataframe(rules_df, use_container_width=True, hide_index=True)

    with col_impact:
        st.markdown("""
        <div class="callout callout-amber">
            <strong>How DQ Feeds Discovery:</strong><br/><br/>
            1. Each record gets a DQ score (0–100)<br/>
            2. Candidate pairs average both scores → DQ_WEIGHTED_SCORE<br/>
            3. Catalog selects best match weighted by DQ<br/>
            4. Survivorship trusts higher-DQ sources
        </div>
        """, unsafe_allow_html=True)


# ═══════════════════════════════════════════════════════════════════
# TAB 5: GOLDEN MASTER
# ═══════════════════════════════════════════════════════════════════
with tab5:

    st.markdown("""
    <div class="callout callout-blue">
        <strong>The Golden Record:</strong> Each entity is resolved through connected-component analysis,
        survivorship selects the best attribute value from prioritized sources, and the golden key
        (BRAND|PRODUCT_NAME|SIZE) ensures uniqueness. The result: one authoritative record per product.
    </div>
    """, unsafe_allow_html=True)

    with st.spinner("Loading master data..."):
        df_master = q("SELECT * FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER")

    m1, m2, m3, m4, m5 = st.columns(5)
    m1.metric("Golden Records", f"{len(df_master):,}")
    m2.metric("Product Families", "10")
    m3.metric("Product Groups", "6")
    m4.metric("Active Products", f"{int((df_master['DERIVED_PRODUCT_STATUS'] == 'ACTIVE').sum()):,}")
    m5.metric("Under Review", f"{int((df_master['DERIVED_PRODUCT_STATUS'] == 'REVIEW').sum()):,}")

    st.divider()

    col_l, col_r = st.columns(2)

    with col_l:
        st.markdown('<p class="section-title">Product Family Distribution</p>', unsafe_allow_html=True)
        family = df_master["DERIVED_PRODUCT_FAMILY"].value_counts().reset_index()
        family.columns = ["FAMILY", "COUNT"]

        chart = alt.Chart(family).mark_bar(cornerRadiusTopRight=8, cornerRadiusBottomRight=8).encode(
            y=alt.Y("FAMILY:N", sort="-x", title=None),
            x=alt.X("COUNT:Q", title="Products"),
            color=alt.Color("FAMILY:N", legend=None, scale=alt.Scale(scheme="purples")),
            tooltip=["FAMILY", "COUNT"]
        ).properties(height=340)
        st.altair_chart(chart, use_container_width=True)

    with col_r:
        st.markdown('<p class="section-title">Source Contribution to Golden Records</p>', unsafe_allow_html=True)
        source_contrib = pd.DataFrame([
            {"Source": "Inventory", "Records": int(df_master["INVENTORY_PRODUCT_ID"].notna().sum())},
            {"Source": "Ecommerce", "Records": int(df_master["ECOMMERCE_PRODUCT_ID"].notna().sum())},
            {"Source": "Supplier", "Records": int(df_master["SUPPLIER_PRODUCT_ID"].notna().sum())},
            {"Source": "ERP", "Records": int(df_master["ERP_PRODUCT_ID"].notna().sum())},
        ])

        chart = alt.Chart(source_contrib).mark_arc(innerRadius=80, outerRadius=150).encode(
            theta=alt.Theta("Records:Q"),
            color=alt.Color("Source:N", scale=alt.Scale(range=C["systems"])),
            tooltip=["Source", "Records"]
        ).properties(height=340)
        st.altair_chart(chart, use_container_width=True)

    st.divider()

    st.markdown('<p class="section-title">Survivorship Priority (Who Wins?)</p>', unsafe_allow_html=True)

    surv_data = q("""
        SELECT ATTRIBUTE_NAME, SOURCE_SYSTEM, PRIORITY_ORDER
        FROM RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP
        WHERE ACTIVE_FLAG = 'Y' ORDER BY ATTRIBUTE_NAME, PRIORITY_ORDER
    """)

    if not surv_data.empty:
        surv_data["SYSTEM"] = surv_data["SOURCE_SYSTEM"].str.replace("_PRODUCT", "")
        chart = alt.Chart(surv_data).mark_rect(cornerRadius=6).encode(
            x=alt.X("ATTRIBUTE_NAME:N", title=None, axis=alt.Axis(labelAngle=-30)),
            y=alt.Y("SYSTEM:N", title=None),
            color=alt.Color("PRIORITY_ORDER:Q",
                           scale=alt.Scale(scheme="yelloworangered", reverse=True, domain=[1, 4]),
                           title="Priority (1=Best)"),
            tooltip=["ATTRIBUTE_NAME", "SOURCE_SYSTEM", "PRIORITY_ORDER"]
        ).properties(height=180)

        text = alt.Chart(surv_data).mark_text(fontSize=16, fontWeight="bold").encode(
            x="ATTRIBUTE_NAME:N", y="SYSTEM:N",
            text=alt.Text("PRIORITY_ORDER:Q"),
            color=alt.condition(alt.datum.PRIORITY_ORDER <= 2, alt.value("white"), alt.value("#1e293b"))
        )
        st.altair_chart(chart + text, use_container_width=True)

    st.divider()

    st.markdown('<p class="section-title">Processing Audit Trail</p>', unsafe_allow_html=True)
    a1, a2, a3, a4 = st.columns(4)
    a1.metric("P10 — Entity Creation", "5,567")
    a1.caption("Connected-component resolution")
    a2.metric("P12 — Family Derivation", "5,567")
    a2.caption("CATEGORY → PRODUCT_FAMILY")
    a3.metric("P13 — Group Derivation", "5,567")
    a3.caption("FAMILY → PRODUCT_GROUP")
    a4.metric("P14 — Status Assignment", "5,567")
    a4.caption("GROUP → ACTIVE/REVIEW")

    st.markdown("""
    <div class="callout callout-green" style="margin-top:16px;">
        <strong>100% Success Rate</strong> — All 22,268 actions across 4 processing phases completed successfully.
        Every entity has full version history and audit lineage traceable to source records.
    </div>
    """, unsafe_allow_html=True)


# ═══════════════════════════════════════════════════════════════════
# TAB 6: ARCHITECTURE
# ═══════════════════════════════════════════════════════════════════
with tab6:

    st.markdown("""
    <div class="callout callout-blue">
        <strong>16-Phase Architecture</strong> — A fully metadata-driven, auditable MDM pipeline built entirely on Snowflake.
        Business rules are separated from state management. Every change is versioned. Every decision is traceable.
    </div>
    """, unsafe_allow_html=True)

    col_l, col_r = st.columns([3, 2])

    with col_l:
        st.markdown('<p class="section-title">End-to-End Pipeline</p>', unsafe_allow_html=True)
        st.code("""
┌─────────────────────────────────────────────────────────┐
│  P1   Platform Setup (Database, Schemas, Roles)         │
│  P2   Source Tables (ERP, Supplier, Inventory, Ecomm)   │
│  P3   Test Data Generation (10K+ per source)            │
│  P4   Metadata (DQ Rules, Survivorship, Mappings)       │
└───────────────────────────┬─────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│  P5   SOURCE_SUPERSET — Canonical harmonization         │
│  P6   DQ_RESULTS — Score every record (0–100)          │
│  P7   RELATIONSHIP_CANDIDATES — 21.8M pairs evaluated  │
│  P8   RELATIONSHIP_CATALOG — Best-match selection       │
└───────────────────────────┬─────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│  P9   Master Framework (DDL + ACTION_LOG)               │
│  P10  Entity Resolution → CREATE actions                │
│  P11  DAL — Apply actions to INTM_PRODUCT_MASTER        │
└───────────────────────────┬─────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│  P12  Derive PRODUCT_FAMILY → UPDATE actions → DAL      │
│  P13  Derive PRODUCT_GROUP → UPDATE actions → DAL       │
│  P14  Derive PRODUCT_STATUS → UPDATE actions → DAL      │
└───────────────────────────┬─────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│  P15  Publish FINAL.PRODUCT_MASTER (active only)        │
│  P16  Security Layer (RBAC + Dynamic Masking)           │
└─────────────────────────────────────────────────────────┘
""", language=None)

    with col_r:
        st.markdown('<p class="section-title">Design Principles</p>', unsafe_allow_html=True)

        st.markdown("""
        <div class="callout callout-purple" style="margin-bottom:10px;">
            <strong>Separation of Concerns</strong><br/>
            Business Rules generate actions.<br/>
            DAL applies actions to state.<br/>
            Neither crosses the boundary.
        </div>
        """, unsafe_allow_html=True)

        st.markdown("""
        <div class="callout callout-green" style="margin-bottom:10px;">
            <strong>Full Auditability</strong><br/>
            Every change = new version.<br/>
            No physical deletes.<br/>
            ACTION_SOURCE traces lineage.
        </div>
        """, unsafe_allow_html=True)

        st.markdown("""
        <div class="callout callout-amber" style="margin-bottom:10px;">
            <strong>Metadata-Driven</strong><br/>
            DQ rules: MD_ATTRIBUTE_DQ_RULES<br/>
            Survivorship: MD_ATTRIBUTE_SURVIVORSHIP<br/>
            Mappings: MD_ATTRIBUTE_MAPPING
        </div>
        """, unsafe_allow_html=True)

        st.markdown("""
        <div class="callout callout-blue" style="margin-bottom:10px;">
            <strong>Security-First</strong><br/>
            4 RBAC roles (Admin → Consumer)<br/>
            3 Dynamic Masking policies<br/>
            Least-privilege by default
        </div>
        """, unsafe_allow_html=True)

    st.divider()

    st.markdown('<p class="section-title">Technology Stack</p>', unsafe_allow_html=True)
    t1, t2, t3, t4 = st.columns(4)
    t1.metric("Platform", "Snowflake")
    t1.caption("Native SQL + Snowpark")
    t2.metric("Visualization", "Streamlit")
    t2.caption("In-Snowflake deployment")
    t3.metric("Governance", "RBAC + Masking")
    t3.caption("Enterprise-grade security")
    t4.metric("Architecture", "16 Phases")
    t4.caption("Modular, testable, auditable")
