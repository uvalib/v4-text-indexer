<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- To map a field, if it's simply renaming it, add it to this list.   Otherwise, add templates to handle it below.  To drop a field, stimply omit from either place -->
    <xsl:variable name="fieldMap">
        <map v3="id" v4="id"/>
        <map v3="author_facet" v4="author_tsearchf_stored" />
        <map v3="composition_era_facet" v4="composition_era_tsearchf_stored" />
        <map v3="date_text" v4="published_display_tsearch_stored" />
        <map v3="digital_collection_facet" v4="digital_collection_tsearchf_stored" />
        <map v3="format_facet" v4="format_tsearchf_stored" />
        <map v3="language_facet" v4="language_tsearchf_stored" />
        <map v3="language_facet" v4="language_note_a" />
        <map v3="shadowed_location_facet" v4="shadowed_location_f"/>
        <map v3="subject_text" v4="subject_tsearchf_stored"/>
        <map v3="subject_facet" v4="subject_tsearchf_stored"/>
        <map v3="title_display" v4="title_tsearch_stored"/>
        <map v3="linked_title_display" v4="title_alternate_tsearch_stored"/>
        <map v3="main_title_display" v4="full_title_tsearchf_stored"/>
        <map v3="vern_title_display" v4="title_vern_tsearch_stored"/>
        <map v3="note_display" v4="note_a"/>
        <map v3="title_sort_facet" v4="title_ssort_stored"/>
        <map v3="fulltext" v4="fulltext_large_highlight"/> 
    </xsl:variable>
    
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:template match="add">
        <xsl:copy>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="doc">
        <doc>
            <field name="circulating_f">true</field>
            <field name="pool_f">catalog</field>
            <field name="uva_availability_f_stored">Online</field>
            <field name="anon_availability_f_stored">Online</field>
            <!-- <field name="record_date_stored">
                <xsl:value-of select="current-dateTime()"/>
            </field>  -->
            <field name="work_title3_key_sort"><xsl:value-of select="concat(translate(normalize-space(field[@name = 'title_sort_facet']/text()), ' &quot;', '_'), '//Book')" /></field>
            <field name="work_title2_key_sort"><xsl:value-of select="concat(translate(normalize-space(field[@name = 'title_sort_facet']/text()), ' &quot;', '_'), '/', translate(normalize-space(field[@name = 'author_sort_facet'][1]/text()), ' ', '_'), '/Book')" /></field>
            <field name="mss_work_key_ssort_stored"><xsl:value-of select="concat(translate(normalize-space(field[@name = 'title_sort_facet']/text()), ' &quot;', '_'), '/', translate(normalize-space(field[@name = 'author_sort_facet'][1]/text()), ' ', '_'), '/Book')" /></field>
            
            <xsl:apply-templates select="*"/>
        </doc>
    </xsl:template>
    
    <xsl:template match="field[@name = 'desc_meta_file_display']">
        <!-- delete the desc_meta_file_display field -->
    </xsl:template>
    <xsl:template match="field[@name = 'admin_meta_file_display']">
        <!-- delete the admin_meta_file_display field -->
    </xsl:template>
    <!-- <xsl:template match="field[@name = 'fulltext']">
        <!- - delete the fulltext field - ->
    </xsl:template> -->
    <xsl:template match="field[@name = 'year_multisort_i']">
        <field name="published_date">
            <xsl:value-of select="concat(text(), '-01-01T00:00:00Z')"/>
        </field>
        <field name="published_daterange">
            <xsl:value-of select="text()"/>
        </field>
        <field name="published_display_a">
            <xsl:value-of select="text()"/>
        </field>
    </xsl:template>
    
    <xsl:template match="field[@name='datafile_name_display']">
        <xsl:variable name="xtf_url"><xsl:text>http://xtf.lib.virginia.edu/xtf/view?docId=</xsl:text><xsl:value-of select="replace(text(), '/FedoraRepo/text/', '')"/></xsl:variable>
        <field name="url_str_stored"><xsl:value-of select="$xtf_url"/></field>
        <field name="data_source_f_stored">etext</field>
        <field name="url_label_str_stored">Read Online</field>
    </xsl:template>
    
    <xsl:template match="field">
        <xsl:variable name="value">
            <xsl:apply-templates select="node()" mode="copy" />
        </xsl:variable>
        <xsl:variable name="v3FieldName" select="@name"/>
        <xsl:variable name="mapEntry" select="$fieldMap/map[@v3 = $v3FieldName]"/>
        <xsl:for-each select="$fieldMap/map[@v3 = $v3FieldName]">
            <field>
                <xsl:attribute name="name" select="@v4"/>
                <xsl:value-of select="$value" />
                <xsl:if test="@suffix">
                    <xsl:value-of select="@suffix" />
                </xsl:if>
            </field>
        </xsl:for-each>
        <xsl:if test="not($mapEntry)">
            <field name="virgo3_tsearch">
                <xsl:apply-templates select="node()" mode="copy"/>
            </field>
            <xsl:comment>Unmapped V3 "<xsl:value-of select="$v3FieldName"/>" field will only be text-searchable.</xsl:comment>
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- ======================================================================= -->
    <!-- DEFAULT TEMPLATE                                                        -->
    <!-- ======================================================================= -->
    
    
    <!--  <xsl:template match="@* | node()">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>
    
    <xsl:template match="@* | node()">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>  -->

</xsl:stylesheet>
