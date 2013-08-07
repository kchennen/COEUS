<%-- 
    Document   : index
    Created on : May 28, 2013, 11:20:32 AM
    Author     : sernadela
--%>

<%@include file="/layout/taglib.jsp" %>
<s:layout-render name="/setup/html.jsp">
    <s:layout-component name="title">COEUS Setup</s:layout-component>
    <s:layout-component name="custom_scripts">
        <script src="<c:url value="/assets/js/jquery.js" />"></script>
        <script src="<c:url value="/assets/js/coeus.sparql.js" />"></script>
        <script src="<c:url value="/assets/js/coeus.api.js" />"></script>
        <script type="text/javascript">
            /*function appendConcept(data, query, key) {
             $.get(query, function(dataconcepts, status) {
             var c = '';
             for (var k = 0, s = dataconcepts.results.bindings.length; k < s; k++) {
             c += '<li>' + dataconcepts.results.bindings[k].c.value + '</li>';
             }
             $('#' + data[key]).append(c);
             console.log('Append on #' + data[key] + ': ' + c);
             }, 'json');
             }
             
             function fillConcepts(data) {
             console.log('Concepts: ' + data);
             for (var key = 0, size = data.length; key < size; key++) {
             var q = "PREFIX+coeus%3A+%3Chttp%3A%2F%2Fbioinformatics.ua.pt%2Fcoeus%2Fresource%2F%3E%0D%0APREFIX+dc%3A+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Felements%2F1.1%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Fc+%3Fconcept+%7B%3Fconcept+coeus%3AhasEntity+coeus%3Aentity_" + data[key] + "+.+%3Fconcept+dc%3Atitle+%3Fc%7D";
             var query = "../sparql?query=" + q + "&output=json";
             appendConcept(data, query, key);
             }
             }
             
             function fillEntities() {
             var query = "PREFIX+coeus%3A+%3Chttp%3A%2F%2Fbioinformatics.ua.pt%2Fcoeus%2Fresource%2F%3E%0D%0APREFIX+dc%3A+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Felements%2F1.1%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Fe+%3Fentity+%7B%3Fs+coeus%3AhasEntity+%3Fentity+.+%3Fentity+dc%3Atitle+%3Fe%7D";
             var q = "../sparql?query=" + query + "&output=json";
             var e = '';
             $.ajax({url: q, dataType: 'json'}).done(function(data) {
             var array = new Array();
             for (var key = 0, size = data.results.bindings.length; key < size; key++) {
             
             array[key] = data.results.bindings[key].e.value;
             
             e += '<p class="text-info">'
             + array[key] + '<ul id=' + array[key] + '></ul></p>';
             
             }
             $('#concepts').append(e);
             fillConcepts(array);
             
             }).fail(function(jqXHR, textStatus) {
             console.log('[COEUS] unable to complete request. ' + textStatus);
             // Server communication error function handler.
             });
             }*/

            function queryConcepts(entity, query) {
                var qConcepts = "SELECT DISTINCT ?c ?concept {?concept coeus:hasEntity coeus:entity_" + entity + " . ?concept dc:title ?c  }";
                var c = '';
                query.query(qConcepts, {success: function(json) {
                        for (var i = 0, s = json.results.bindings.length; i < s; i++) {
                            c += '<p><a href=' + json.results.bindings[i].concept.value + '><i class="icon-search"></i></a> ' + json.results.bindings[i].c.value + '</p>';

                        }
                        $('#entity_' + entity).append(c);
                        console.log('Append on #' + entity + ': ' + c);
                    }});
            }

            function selectEntity() {
                var path = lastPath();
                window.location = "../entity/" + path;
            }

            function fillHeader(result) {
                $('#header').html('<h1>' + lastPath() + '<small id="env"> ' + result.config.environment + '</small></h1>');
            }
            function fillEnvironments(result) {
                console.log(result);
                var array = result.environments;
                for (var r in array) {
                    var value = array[r].replace('env_', '');
                    $('#environments').append('<option>' + value + '</option>');
                }
            }

            $(document).ready(function() {
                //get seed from url
                var seed = lastPath();
                callURL("../../config/getconfig/", fillHeader);
                callURL("../../config/listenv/", fillEnvironments);

                var query = initSparqlerQuery();
                // passes standard JSON results object to success callback
                var qEntities = "SELECT DISTINCT ?entity ?e ?s {" + seed + " coeus:includes ?entity . ?concept coeus:hasEntity ?entity . ?entity dc:title ?e . }";

                query.query(qEntities,
                        {success: function(json) {
                                // fill Entities
                                var arrayOfEntities = new Array();
                                var e = '';
                                for (var key = 0, size = json.results.bindings.length; key < size; key++) {
                                    arrayOfEntities[key] = json.results.bindings[key].e.value;

                                    e += '<p class="text-info"><a href=' + json.results.bindings[key].entity.value + '>'
                                            + arrayOfEntities[key] + '</a><ul id=entity_' + arrayOfEntities[key] + '></ul></p>';

                                }
                                $('#concepts').append(e);

                                // fill Concepts
                                for (var k = 0, s = arrayOfEntities.length; k < s; k++) {
                                    //$('#addentity').append('<option>' + arrayOfEntities[k] + '</option>');
                                    queryConcepts(arrayOfEntities[k], query);
                                }
                            }}
                );
                //header name
                //$.get('../home/config', function(config, status) {
                //   console.log(config);        

                // }, 'json'); 

                var qseeds = "SELECT DISTINCT ?seed ?s {?seed a coeus:Seed . ?seed dc:title ?s . }";

                query.query(qseeds,
                        {success: function(json) {
                                // fill Concepts
                                for (var k = 0, s = json.results.bindings.length; k < s; k++) {
                                    $('#seeds').append('<option>' + splitURIPrefix(json.results.bindings[k].seed.value).value + '</option>');
                                }
                                $('#seeds option:contains(' + lastPath().split('coeus:')[1] + ')').prop({selected: true});
                            }}
                );
            });

            function changeSeed() {
                var title = $('#seeds').val();
                redirect("../seed/" + "coeus:" + title);
            }

            function changeEnv() {
                var env = $('#environments').val();
                callURL("../../config/upenv/" + env, changeEnvResult, changeEnvResult, changeEnvError);
            }
            function changeEnvResult(result) {
                if (result.status === 100)
                    callURL("../../config/getconfig/", fillHeader);
                else
                    $('#info').html(generateHtmlMessage("Warning!", result.message));
            }
            function changeEnvError(result, text) {
                $('#info').html(generateHtmlMessage("ERROR!", text, "alert-error"));
            }

        </script>
    </s:layout-component>
    <s:layout-component name="body">

        <div class="container">
            <br><br>
            <div id="header" class="page-header">

            </div>
            <div id="info"></div>
            <div class="row-fluid">
                <div id="concepts"class="span6">
                    <h4>Knowledge Base <small>(Entity-Concept)</small></h4>
                    <!--<p class="text-info">Disease</p>
                    <ul>
                        <li>OMIM <span class="badge">1123</span></li>
                        <li>Orphanet <span class="badge">133</span></li>
                    </ul>
                    <p class="text-info">Drug</p>
                    <ul>
                        <li>PharmGKB <span class="badge">22331</span></li>
                    </ul>-->
                </div>
                <div class="span6">
                    <h4>Actions</h4>

                    <div class="row-fluid">
                        <div class="span4">
                            Seeds
                        </div>
                        <div  class="span4">
                            <select class="span10" id="seeds">

                            </select>
                        </div>
                        <div class="span4">
                            <div class="btn-group">
                                <a onclick="changeSeed();" class="btn btn-danger">Change seed</a>
                            </div>
                        </div>
                    </div>

                    <div class="row-fluid">
                        <div class="span4">
                            Environments
                        </div>
                        <div class="span4">
                            <select class="span10" id="environments">
                            </select>
                        </div>
                        <div class="span4">
                            <div class="btn-group">
                                <a onclick="changeEnv();" class="btn btn-danger">Change environment</a>
                            </div>
                        </div>
                    </div>

                    <div class="row-fluid">
                        <div class="span4">

                        </div>
                        <div class="span4">

                        </div>
                        <div class="span4">
                            <div class="btn-group">
                                <a onclick="selectEntity();" class="btn btn-large btn-primary">Manage Entities</a>

                            </div>
                        </div>
                    </div>


                </div>
            </div>



        </div>

    </s:layout-component>
</s:layout-render>
