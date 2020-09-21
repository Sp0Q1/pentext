<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ros="http://www.radical.sexy" xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs ros" version="2.0">

    <!-- Setting the source document explicitly to facilitate testing -->
    <xsl:variable name="source-document" as="document-node()" select="."/>
    <xsl:variable name="test" select="local-name(.)"/>

    <!-- color scheme, just change these to change colors throughout the suite -->
    <xsl:variable name="c_main">#e2632a</xsl:variable>
    <xsl:variable name="c_support_light">#ededed</xsl:variable>
    <xsl:variable name="c_support_subtlydarkerlight">#e4e4e4</xsl:variable>
    <!-- used for subtle light border around support_light background -->
    <xsl:variable name="c_support_medium">#999999</xsl:variable>
    <!-- used for subtle light border around support_light background -->
    <xsl:variable name="c_support_dark">#444444</xsl:variable>
    <xsl:variable name="c_main_contrast">white</xsl:variable>

    <xsl:variable name="border-color">#444444</xsl:variable>

    <!-- auto numbering format (used in various docs) -->
    <xsl:param name="AUTO_NUMBERING_FORMAT" select="'1.1.1'"/>

    <!-- executive summary (report only) -->
    <xsl:param name="EXEC_SUMMARY" select="false()"/>

    <!-- language parameter for localization (quote & invoice) -->
    <xsl:param name="lang" select="/*/@xml:lang"/>

    <!-- keys for numbering (used in report) -->
    <xsl:key name="rosid" match="section | finding | appendix | non-finding" use="@id"/>

    <!-- key for bibliographies (for general document) -->
    <xsl:key name="biblioid" match="biblioentry" use="@id"/>

    <!-- contract variables -->
    <xsl:variable name="hourly_fee" select="/contract/meta/contractor/hourly_fee * 1"/>
    <xsl:variable name="plannedHours" select="/contract/meta/work/planning/hours * 1"/>
    <xsl:variable name="total_fee" select="$hourly_fee * $plannedHours"/>

    <!-- current second ('random' seed) -->
    <xsl:variable name="current_second" select="ceiling(seconds-from-dateTime(current-dateTime()))"/>

    <!-- finding colors (used in findings & pie charts) -->
    <!-- threatlevel -->
    <xsl:variable name="color_extreme">#000000</xsl:variable>
    <xsl:variable name="color_high">#922D00</xsl:variable>
    <xsl:variable name="color_elevated">#E2632A</xsl:variable>
    <xsl:variable name="color_moderate">#FFA67E</xsl:variable>
    <xsl:variable name="color_low">#F7D4C4</xsl:variable>
    <xsl:variable name="color_na">silver</xsl:variable>
    <xsl:variable name="color_unknown">#EDD382</xsl:variable>
    <!-- status -->
    <xsl:variable name="color_new">#CC4900</xsl:variable>
    <xsl:variable name="color_unresolved">#FF5C00</xsl:variable>
    <xsl:variable name="color_notretested">#FE9920</xsl:variable>
    <xsl:variable name="color_resolved">#15B01A</xsl:variable>

    <!-- generic pie chart colors -->
    <xsl:variable name="generic_piecolor_1">#D9D375</xsl:variable>
    <xsl:variable name="generic_piecolor_2">#B9A44C</xsl:variable>
    <xsl:variable name="generic_piecolor_3">#BEC5AD</xsl:variable>
    <xsl:variable name="generic_piecolor_4">#7CA982</xsl:variable>
    <xsl:variable name="generic_piecolor_5">#566E3D</xsl:variable>
    <xsl:variable name="generic_piecolor_6">#5B5F97</xsl:variable>
    <xsl:variable name="generic_piecolor_7">#C200FB</xsl:variable>
    <xsl:variable name="generic_piecolor_8">#A9E5BB</xsl:variable>
    <xsl:variable name="generic_piecolor_9">#98C1D9</xsl:variable>
    <xsl:variable name="generic_piecolor_10">#5B5F97</xsl:variable>
    <xsl:variable name="generic_piecolor_11">burlywood</xsl:variable>
    <xsl:variable name="generic_piecolor_12">cornflowerblue</xsl:variable>
    <!-- that's right people, cornflower blue -->
    <xsl:variable name="generic_piecolor_13">darksalmon</xsl:variable>
    <xsl:variable name="generic_piecolor_14">goldenrod</xsl:variable>
    <xsl:variable name="generic_piecolor_15">lightslategray</xsl:variable>
    <xsl:variable name="generic_piecolor_16">mediumpurple</xsl:variable>
    <xsl:variable name="generic_piecolor_17">teal</xsl:variable>
    <xsl:variable name="generic_piecolor_18">yellow</xsl:variable>
    <xsl:variable name="generic_piecolor_19">sienna</xsl:variable>
    <xsl:variable name="generic_piecolor_20">mediumturquoise</xsl:variable>
    <xsl:variable name="generic_piecolor_21">navy</xsl:variable>
    <xsl:variable name="generic_piecolor_other">black</xsl:variable>

    <xsl:variable name="serviceNodeSet">
        <!-- putting the logic for all calculation in this imaginary nodeset; output to fo comes below -->
        <xsl:for-each select="//breakdown/service | //breakdown/extra">
            <xsl:variable name="minmaxeffortPresent" select="boolean(effort/min and effort/max)"/>
            <xsl:variable name="minmaxFeePresent" select="boolean(fee/min and fee/max)"/>
            <xsl:variable name="effortPresent"
                select="boolean(normalize-space(effort) and normalize-space(effort/@in))"/>
            <xsl:variable name="optional" select="@optional = 'yes'"/>
            <entry>
                <xsl:attribute name="denomination">
                    <xsl:value-of select="fee/@denomination"/>
                </xsl:attribute>
                <xsl:attribute name="estimate">
                    <xsl:value-of select="fee/@estimate = 'yes'"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="local-name(.)"/>
                </xsl:attribute>
                <xsl:attribute name="optional">
                    <xsl:value-of select="@optional"/>
                </xsl:attribute>
                <desc>
                    <xsl:if test="$optional">
                        <xsl:text>(Optional) </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="specification"/>
                </desc>
                <xsl:if test="$effortPresent">
                    <d>
                        <xsl:choose>
                            <xsl:when test="$minmaxeffortPresent">
                                <!-- Estimated effort -->
                                <xsl:value-of select="effort/min"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="effort/max"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="effort/@in"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Actual effort -->
                                <xsl:value-of select="effort"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="effort/@in"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </d>
                    <dh>
                        <!-- effort in hours, for calculation of persondays -->
                        <xsl:choose>
                            <xsl:when test="$minmaxeffortPresent">
                                <!-- computed + estimated fee; compute for min and max using effort and use hourly rate denomination -->
                                <min>
                                    <xsl:choose>
                                        <xsl:when test="$optional">0</xsl:when>
                                        <xsl:when test="effort/@in = 'hours'">
                                            <xsl:value-of select="effort/min"/>
                                        </xsl:when>
                                        <xsl:when test="effort/@in = 'days'">
                                            <xsl:value-of select="effort/min * 8"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </min>
                                <max>
                                    <xsl:choose>
                                        <xsl:when test="effort/@in = 'hours'">
                                            <xsl:value-of select="effort/max"/>
                                        </xsl:when>
                                        <xsl:when test="effort/@in = 'days'">
                                            <xsl:value-of select="effort/max * 8"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </max>
                            </xsl:when>
                            <xsl:otherwise>
                                <min>
                                    <xsl:choose>
                                        <xsl:when test="$optional">0</xsl:when>
                                        <xsl:when test="effort/@in = 'hours'">
                                            <xsl:value-of select="effort"/>
                                        </xsl:when>
                                        <xsl:when test="effort/@in = 'days'">
                                            <xsl:value-of select="effort * 8"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </min>
                                <max>
                                    <xsl:choose>
                                        <xsl:when test="effort/@in = 'hours'">
                                            <xsl:value-of select="effort"/>
                                        </xsl:when>
                                        <xsl:when test="effort/@in = 'days'">
                                            <xsl:value-of select="effort * 8"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </max>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dh>
                    <h>
                        <xsl:value-of select="hourly_rate"/>
                    </h>
                </xsl:if>
                <f>
                    <xsl:choose>
                        <xsl:when test="fee/computed">
                            <!-- Fee computed; need effort and rate -->
                            <xsl:choose>
                                <xsl:when test="not($effortPresent) or not(hourly_rate)">
                                    <xsl:message terminate="yes">ERROR: cannot compute fee for
                                            <xsl:value-of select="local-name(.)"/> "<xsl:value-of
                                            select="specification"/>" - effort and/or hourly rate
                                        missing </xsl:message>
                                </xsl:when>
                                <xsl:when test="$effortPresent and $minmaxeffortPresent">
                                    <!-- computed + estimated fee; compute for min and max using effort and use hourly rate denomination -->
                                    <min>
                                        <xsl:choose>
                                            <xsl:when test="$optional">0</xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="computeFee">
                                                  <xsl:with-param name="hourlyRate"
                                                  select="hourly_rate" as="xs:decimal"/>
                                                  <xsl:with-param name="effort" select="effort/min"/>
                                                  <xsl:with-param name="in" select="effort/@in"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </min>
                                    <max>
                                        <xsl:call-template name="computeFee">
                                            <xsl:with-param name="hourlyRate" select="hourly_rate"
                                                as="xs:decimal"/>
                                            <xsl:with-param name="effort" select="effort/max"/>
                                            <xsl:with-param name="in" select="effort/@in"/>
                                        </xsl:call-template>
                                    </max>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- computed fee; compute using effort and use hourly rate denomination -->
                                    <min>
                                        <xsl:choose>
                                            <xsl:when test="$optional">0</xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="computeFee">

                                                  <xsl:with-param name="hourlyRate"
                                                  select="hourly_rate" as="xs:decimal"/>
                                                  <xsl:with-param name="effort" select="effort"
                                                  as="xs:decimal"/>
                                                  <xsl:with-param name="in" select="effort/@in"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </min>
                                    <max>
                                        <xsl:call-template name="computeFee">
                                            <xsl:with-param name="hourlyRate" select="hourly_rate"
                                                as="xs:decimal"/>
                                            <xsl:with-param name="effort" select="effort"
                                                as="xs:decimal"/>
                                            <xsl:with-param name="in" select="effort/@in"/>
                                        </xsl:call-template>
                                    </max>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Fee set by user -->
                            <xsl:choose>
                                <xsl:when test="$minmaxFeePresent">
                                    <xsl:copy-of select="fee/node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <min>
                                        <xsl:copy-of select="fee/text()"/>
                                    </min>
                                    <max>
                                        <xsl:copy-of select="fee/text()"/>
                                    </max>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </f>
            </entry>
        </xsl:for-each>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Compute the fee by multiplying hourly rate with time spent</xd:desc>
        <xd:param name="hourlyRate">Hourly rate</xd:param>
        <xd:param name="effort">Time spent; can be expressed in hours or days (see 'in')</xd:param>
        <xd:param name="in">hours|days</xd:param>
    </xd:doc>
    <xsl:template name="computeFee" as="xs:decimal">
        <xsl:param name="hourlyRate" as="xs:decimal"/>
        <xsl:param name="effort" as="xs:decimal"/>
        <xsl:param name="in" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$in = 'hours'">
                <!-- multiply with hourly rate -->
                <xsl:value-of select="$effort * $hourlyRate"/>
            </xsl:when>
            <xsl:when test="$in = 'days'">
                <!-- multiply with hourly rate * 8 -->
                <xsl:value-of select="$effort * $hourlyRate * 8"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="selectColor">
        <xsl:param name="label"/>
        <xsl:param name="position"/>
        <xsl:choose>
            <!-- specific cases -->
            <!-- threat level -->
            <xsl:when test="$label = 'Extreme'">
                <xsl:value-of select="$color_extreme"/>
            </xsl:when>
            <xsl:when test="$label = 'High'">
                <xsl:value-of select="$color_high"/>
            </xsl:when>
            <xsl:when test="$label = 'Elevated'">
                <xsl:value-of select="$color_elevated"/>
            </xsl:when>
            <xsl:when test="$label = 'Moderate'">
                <xsl:value-of select="$color_moderate"/>
            </xsl:when>
            <xsl:when test="$label = 'Low'">
                <xsl:value-of select="$color_low"/>
            </xsl:when>
            <xsl:when test="$label = 'N/A'">
                <xsl:value-of select="$color_na"/>
            </xsl:when>
            <xsl:when test="$label = 'Unknown'">
                <xsl:value-of select="$color_unknown"/>
            </xsl:when>
            <!-- status -->
            <xsl:when test="$label = 'new'">
                <xsl:value-of select="$color_new"/>
            </xsl:when>
            <xsl:when test="$label = 'unresolved'">
                <xsl:value-of select="$color_unresolved"/>
            </xsl:when>
            <xsl:when test="$label = 'not_retested'">
                <xsl:value-of select="$color_notretested"/>
            </xsl:when>
            <xsl:when test="$label = 'resolved'">
                <xsl:value-of select="$color_resolved"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- generic pie chart -->
                <xsl:choose>
                    <!-- Going with shades of green, yellow and blue/purple in all cases here so as not to imply severity levels -->
                    <xsl:when test="$position = 1">
                        <xsl:value-of select="$generic_piecolor_1"/>
                    </xsl:when>
                    <xsl:when test="$position = 2">
                        <xsl:value-of select="$generic_piecolor_2"/>
                    </xsl:when>
                    <xsl:when test="$position = 3">
                        <xsl:value-of select="$generic_piecolor_3"/>
                    </xsl:when>
                    <xsl:when test="$position = 4">
                        <xsl:value-of select="$generic_piecolor_4"/>
                    </xsl:when>
                    <xsl:when test="$position = 5">
                        <xsl:value-of select="$generic_piecolor_5"/>
                    </xsl:when>
                    <xsl:when test="$position = 6">
                        <xsl:value-of select="$generic_piecolor_6"/>
                    </xsl:when>
                    <xsl:when test="$position = 7">
                        <xsl:value-of select="$generic_piecolor_7"/>
                    </xsl:when>
                    <xsl:when test="$position = 8">
                        <xsl:value-of select="$generic_piecolor_8"/>
                    </xsl:when>
                    <xsl:when test="$position = 9">
                        <xsl:value-of select="$generic_piecolor_9"/>
                    </xsl:when>
                    <xsl:when test="$position = 10">
                        <xsl:value-of select="$generic_piecolor_10"/>
                    </xsl:when>
                    <xsl:when test="$position = 11">
                        <xsl:value-of select="$generic_piecolor_11"/>
                    </xsl:when>
                    <xsl:when test="$position = 12">
                        <xsl:value-of select="$generic_piecolor_12"/>
                    </xsl:when>
                    <xsl:when test="$position = 13">
                        <xsl:value-of select="$generic_piecolor_13"/>
                    </xsl:when>
                    <xsl:when test="$position = 14">
                        <xsl:value-of select="$generic_piecolor_14"/>
                    </xsl:when>
                    <xsl:when test="$position = 15">
                        <xsl:value-of select="$generic_piecolor_15"/>
                    </xsl:when>
                    <xsl:when test="$position = 16">
                        <xsl:value-of select="$generic_piecolor_16"/>
                    </xsl:when>
                    <xsl:when test="$position = 17">
                        <xsl:value-of select="$generic_piecolor_17"/>
                    </xsl:when>
                    <xsl:when test="$position = 18">
                        <xsl:value-of select="$generic_piecolor_18"/>
                    </xsl:when>
                    <xsl:when test="$position = 19">
                        <xsl:value-of select="$generic_piecolor_19"/>
                    </xsl:when>
                    <xsl:when test="$position = 20">
                        <xsl:value-of select="$generic_piecolor_20"/>
                    </xsl:when>
                    <xsl:when test="$position = 21">
                        <xsl:value-of select="$generic_piecolor_21"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$generic_piecolor_other"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- document version number (mostly for report) -->

    <xsl:variable name="numberOfVersionsInDocument" as="xs:integer">
        <xsl:call-template name="getNumberOfVersions"/>
    </xsl:variable>

    <xsl:template name="getNumberOfVersions" as="xs:integer">
        <xsl:value-of select="count(/pentest_report/meta/version_history/version)"/>
    </xsl:template>

    <xsl:template name="VersionNumber">
        <xsl:param name="number" select="@number"/>
        <xsl:choose>
            <!-- if value is auto, do some autonumbering magic -->
            <xsl:when test="string(@number) = 'auto'"> 0.<xsl:value-of
                    select="$numberOfVersionsInDocument"/>
                <!-- this is really unrobust :D - todo: follow fixed numbering if provided -->
            </xsl:when>
            <xsl:otherwise>
                <!-- just plop down the value -->
                <!-- todo: guard numbering format in schema -->
                <xsl:value-of select="@number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:variable name="latestVersionNumber">
        <xsl:for-each select="/pentest_report/meta/version_history/version">
            <xsl:sort select="xs:dateTime(@date)" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:call-template name="VersionNumber">
                    <xsl:with-param name="number" select="@number"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>


    <!-- document version number (various documents) -->
    <xsl:variable name="latestVersionDate">
        <xsl:choose>
            <xsl:when test="/contract">
                <!-- we're not using versions for contracts, but the contract date will do just fine -->
                <xsl:value-of
                    select="format-date(/contract/meta/work/start_date, '[MNn] [D1], [Y]', 'en', (), ())"
                />
            </xsl:when>
            <xsl:when test="/ratecard">
                <xsl:for-each select="/*/meta/client/rates/latestrevisiondate">
                    <xsl:sort select="xs:dateTime(@date)" order="descending"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="format-dateTime(@date, '[MNn] [D1], [Y]', en, (), ())"
                        />
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/*/meta/version_history/version">
                    <xsl:sort select="xs:dateTime(@date)" order="descending"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of
                            select="format-dateTime(@date, '[MNn] [D1o], [Y]', 'en', (), ())"/>
                        <!-- Note: this should be: 
                    <xsl:value-of select="format-dateTime(@date, $localDateFormat, $lang, (), ())"/> 
                    to properly be localised, but we're using Saxon HE instead of PE/EE and having localised month names 
                    would require creating a LocalizerFactory 
                    See http://www.saxonica.com/html/documentation/extensibility/config-extend/localizing/ for more info
                    sounds like I'd have to know Java for that so for now, the date isn't localised. :) -->
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Finding stuff -->

    <xsl:variable name="findingSummaryTable">
        <xsl:for-each-group select="$source-document//finding" group-by="@threatLevel">
            <xsl:sort data-type="number" order="descending"
                select="
                    (number(current-grouping-key() = 'Extreme') * 10)
                    + (number(current-grouping-key() = 'High') * 9)
                    + (number(current-grouping-key() = 'Elevated') * 8)
                    + (number(current-grouping-key() = 'Moderate') * 7)
                    + (number(current-grouping-key() = 'Low') * 6)
                    + (number(current-grouping-key() = 'Unknown') * 3)
                    + (number(current-grouping-key() = 'N/A') * 1)"/>
            <xsl:variable name="findingThreatLevelClean"
                select="translate(current-grouping-key(), '/', '_')"/>
            <findingEntry>
                <xsl:attribute name="Ref">
                    <xsl:value-of select="@Ref"/>
                </xsl:attribute>
                <xsl:attribute name="status">
                    <xsl:value-of select="@status"/>
                </xsl:attribute>
                <xsl:attribute name="findingId">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <!--<!-\- add an id for the first entry of each type so that we can link to it -\->
                <xsl:if
                    test="not(preceding-sibling::findingEntry/findingThreatLevel = findingThreatLevel)">
                    <xsl:attribute name="id">summaryTableThreatLevel<xsl:value-of
                            select="$findingThreatLevelClean"/></xsl:attribute>
                </xsl:if>-->
                <findingNumber>
                    <xsl:call-template name="getNumber">
                        <xsl:with-param name="elementToNumber" select="."/>
                    </xsl:call-template>
                </findingNumber>
                <findingType>
                    <xsl:value-of select="@type"/>
                </findingType>
                <findingDescription>
                    <xsl:choose>
                        <xsl:when test="description_summary">
                            <xsl:value-of select="description_summary"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="description" mode="summarytable"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </findingDescription>
                <findingThreatLevel>
                    <xsl:value-of select="current-grouping-key()"/>
                </findingThreatLevel>
            </findingEntry>
        </xsl:for-each-group>
    </xsl:variable>

    <!-- Money stuff -->
    <xsl:variable name="eur" select="'eur'"/>
    <xsl:variable name="gbp" select="'gbp'"/>
    <xsl:variable name="usd" select="'usd'"/>
    <xsl:variable name="eur_s" select="'€'"/>
    <xsl:variable name="gbp_s" select="'£'"/>
    <xsl:variable name="usd_s" select="'$'"/>
    <xsl:variable name="denomination">
        <xsl:choose>
            <xsl:when test="/ratecard">
                <xsl:choose>
                    <xsl:when test="//meta/client/rates/@denomination = $eur">
                        <xsl:value-of select="$eur_s"/>
                    </xsl:when>
                    <xsl:when test="//meta/client/rates/@denomination = $gbp">
                        <xsl:value-of select="$gbp_s"/>
                    </xsl:when>
                    <xsl:when test="//meta/client/rates/@denomination = $usd">
                        <xsl:value-of select="$usd_s"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="/contract">
                <xsl:choose>
                    <xsl:when test="/contract/meta/contractor/hourly_fee/@denomination = $eur">
                        <xsl:value-of select="$eur_s"/>
                    </xsl:when>
                    <xsl:when test="/contract/meta/contractor/hourly_fee/@denomination = $gbp">
                        <xsl:value-of select="$gbp_s"/>
                    </xsl:when>
                    <xsl:when test="/contract/meta/contractor/hourly_fee/@denomination = $usd">
                        <xsl:value-of select="$usd_s"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="/offerte">
                <xsl:choose>
                    <xsl:when test="/offerte/meta/activityinfo/fee/@denomination = $eur">
                        <xsl:value-of select="$eur_s"/>
                    </xsl:when>
                    <xsl:when test="/offerte/meta/activityinfo/fee/@denomination = $gbp">
                        <xsl:value-of select="$gbp_s"/>
                    </xsl:when>
                    <xsl:when test="/offerte/meta/activityinfo/fee/@denomination = $usd">
                        <xsl:value-of select="$usd_s"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="/invoice">
                <xsl:choose>
                    <xsl:when test="/invoice/@denomination = $eur">
                        <xsl:value-of select="$eur_s"/>
                    </xsl:when>
                    <xsl:when test="/invoice/@denomination = $gbp">
                        <xsl:value-of select="$gbp_s"/>
                    </xsl:when>
                    <xsl:when test="/invoice/@denomination = $usd">
                        <xsl:value-of select="$usd_s"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <!-- titlecase function -->
    <xd:doc>
        <xd:desc>Capitalizes word except if it's hard-coded to not be capitalized</xd:desc>
    </xd:doc>
    <xsl:function name="ros:titleCase" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="lower-case($s) = ('and', 'or', 'a', 'an', 'the', 'in')">
                <xsl:value-of select="lower-case($s)"/>
            </xsl:when>
            <xsl:when test="$s = upper-case($s)">
                <xsl:value-of select="$s"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat(upper-case(substring($s, 1, 1)), lower-case(substring($s, 2)))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ros:calculatePeriod">
        <xsl:param name="enddate" as="xs:date"/>
        <xsl:param name="startdate" as="xs:date"/>
        <xsl:variable name="startYear" as="xs:integer" select="year-from-date($startdate)"/>
        <xsl:variable name="startMonth" as="xs:integer" select="month-from-date($startdate)"/>
        <xsl:variable name="startDay" as="xs:integer" select="day-from-date($startdate)"/>
        <xsl:variable name="endYear" as="xs:integer" select="year-from-date($enddate)"/>
        <xsl:variable name="endMonth" as="xs:integer" select="month-from-date($enddate)"/>
        <xsl:variable name="endDay" as="xs:integer" select="day-from-date($enddate)"/>
        <xsl:variable name="startMonthNumberOfDays">
            <xsl:choose>
                <xsl:when test="xs:string($startMonth) = '1'">31</xsl:when>
                <xsl:when test="xs:string($startMonth) = '2'">
                    <!-- I hate february -->
                    <xsl:choose>
                        <xsl:when test="$startYear mod 4 != 0">28</xsl:when>
                        <xsl:when test="$startYear mod 100 != 0">29</xsl:when>
                        <xsl:when test="$startYear mod 400 != 0">28</xsl:when>
                        <xsl:otherwise>29</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="xs:string($startMonth) = '3'">31</xsl:when>
                <xsl:when test="xs:string($startMonth) = '4'">30</xsl:when>
                <xsl:when test="xs:string($startMonth) = '5'">31</xsl:when>
                <xsl:when test="xs:string($startMonth) = '6'">30</xsl:when>
                <xsl:when test="xs:string($startMonth) = '7'">31</xsl:when>
                <xsl:when test="xs:string($startMonth) = '8'">31</xsl:when>
                <xsl:when test="xs:string($startMonth) = '9'">30</xsl:when>
                <xsl:when test="xs:string($startMonth) = '10'">31</xsl:when>
                <xsl:when test="xs:string($startMonth) = '11'">30</xsl:when>
                <xsl:when test="xs:string($startMonth) = '12'">31</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="numYears">
            <xsl:choose>
                <xsl:when test="$endMonth > $startMonth">
                    <xsl:sequence select="$endYear - $startYear"/>
                </xsl:when>
                <xsl:when test="$endMonth &lt; $startMonth">
                    <xsl:sequence select="$endYear - $startYear - 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$endDay >= $startDay">
                            <xsl:sequence select="$endYear - $startYear"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- $endDay &lt; $startDay -->
                            <xsl:sequence select="$endYear - $startYear - 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="numMonths">
            <xsl:choose>
                <xsl:when test="$endDay &lt; $startDay">
                    <xsl:sequence select="$endMonth - $startMonth - 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- $endDay >= $startDay -->
                    <xsl:sequence select="$endMonth - $startMonth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="numDays">
            <!--<xsl:choose>
                <xsl:when test="$numMonths &lt; 1 and $numYears &lt; 1">
                    <!-\- only displaying days if contract is for less than a month -\->
                    <xsl:sequence select="($enddate - $startdate) div xs:dayTimeDuration('P1D')"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-\- if contract is longer than a month, don't count days -\->
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:choose>
                <xsl:when test="$endDay - $startDay &lt; 0">
                    <xsl:value-of select="$startMonthNumberOfDays - $startDay + $endDay"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$endDay - $startDay"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$numYears > 0">
            <xsl:value-of select="$numYears"/>
            <xsl:text> year</xsl:text>
            <xsl:if test="$numYears > 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when
                    test="($numMonths > 0 and $numDays = 0) or ($numMonths = 0 and $numDays > 0)">
                    <xsl:text> and </xsl:text>
                </xsl:when>
                <xsl:when test="$numMonths > 0 and $numDays > 0">
                    <xsl:text>, </xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$numMonths > 0">
            <xsl:value-of select="$numMonths"/>
            <xsl:text> month</xsl:text>
            <xsl:if test="$numMonths > 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:if test="$numDays > 0">
                <xsl:text> and </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$numDays > 0">
            <xsl:value-of select="$numDays"/>
            <xsl:text> day</xsl:text>
            <xsl:if test="$numDays > 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    
</xsl:stylesheet>
