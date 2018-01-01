<%--
  User: eurohlam
  Date: 19/10/2017
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="include.jsp"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RSS-2-KINDLE Subscribers Management</title>

    <meta name="viewport" content="width = device-width, initial-scale = 1.0">

    <!-- JQuery -->
    <script src="../js/jquery-3.1.1.js"></script>

    <!-- Bootstrap -->
    <link href="../bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="../bootstrap/css/bootstrap-theme.min.css" rel="stylesheet">
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../bootstrap/js/bootstrap.min.js"></script>
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->

    <!-- Custom css -->
    <link href="../css/sticky-footer.css" rel="stylesheet">

</head>
<body>
<script>
    var rootURL = '/rss2kindle/rest/profile/<%=username%>';

    $(document).ready(function () {

        //toggling
        $("#getsubscr").click(function (event) {
            $("#newsubscrview").hide('fast');
            $("#removesubscrview").hide('fast');
            $('#editsubscrview').hide('fast');
            $('#suspendsubscrview').hide('fast');
            $("#getsubscrview").show('slow');
        });
        $("#newsubscr").click(function (event) {
            $("#removesubscrview").hide('fast');
            $("#getsubscrview").hide('fast');
            $('#editsubscrview').hide('fast');
            $('#suspendsubscrview').hide('fast');
            $("#newsubscrview").show('slow');
        });
        $("#removesubscr").click(function (event) {
            $("#newsubscrview").hide('fast');
            $("#getsubscrview").hide('fast');
            $('#editsubscrview').hide('fast');
            $('#suspendsubscrview').hide('fast');
            $("#removesubscrview").show('slow');
        });
        $("#suspendsubscr").click(function (event) {
            $("#newsubscrview").hide('fast');
            $("#getsubscrview").hide('fast');
            $('#editsubscrview').hide('fast');
            $("#removesubscrview").hide('fast');
            $('#suspendsubscrview').show('slow');
        });

        //on submit
        $("#get_subscr_form").submit(function () {
            findSubscriberById($("#email").val());
            return false;
        });
        $("#edit_subscr_form").submit(function () {
            editSubscriber();
            return false;
        });
        $("#remove_subscr_form").submit(function () {
            removeSubscriberById($("#removeemail").val());
            return false;
        });
        $("#new_subscr_form").submit(function () {
            newSubscriber();
            return false;
        });
        $("#suspend_subscr_form").submit(function () {
            suspendSubscriber($("#suspendemail").val());
            return false;
        });

        //error view
        $(document).ajaxError(function (event, request, settings) {
            $("#errorview").append("<h1>Error in getting data.</h1>");
        })
    });

    function isEmptyText(text) {
        if (text == null || text == '' || text == 'undefined') {
            return true;
        }
        return false;
    }

    function findSubscriberById(id) {
        $('#getresult').append('<p>trying to get data</p>');
        if (!isEmptyText(id)) {
            $.getJSON(rootURL + '/' + id, function (data) {
                //TODO: it should be array
                var table = '<table class="table table-hover">' +
                    '<tr>' +
                    '<th>email</th>' +
                    '<th>name</th>' +
                    '<th>status</th>' +
                    '<th>rss</th></tr>';

                var tr;
                if (data.status === 'terminated')
                    tr = '<tr class="danger"><td>';
                else if (data.status === 'suspended')
                    tr = '<tr class="warning"><td>';
                else
                    tr = '<tr class="active"><td>';

                table = table + tr
                    + data.email + '</td><td>'
                    + data.name + '</td><td>'
                    + data.status + '</td><td>';
                var rsslist = data.rsslist;
                for (j = 0; j < rsslist.length; j++)
                    table = table + rsslist[j].rss + '  status=' + rsslist[j].status + '<br/>';

                table = table + '</td></tr>';
                table = table + '</table>';
                $('#getresult').append(table);

                //show edit form
                $('#editemail').val(data.email);
                $('#editname').val(data.name);
                $('#editrss').val(data.rsslist[0].rss);
                $('#getsubscrview').hide('fast');
                $('#editsubscrview').show('fast');
            })
        }
        else {
            $('#getresult').append('<p>email is empty</p>');
        }
    }

    function removeSubscriberById(id) {
        $.getJSON(rootURL + '/' + id + '/remove', function (data) {
            $('#getresult').append('<p>' + id + '</p><p>Result jopa' + '</p>');
        });
    }

    function newSubscriber() {
        $.post(rootURL + '/new',
            {
                email: $("#newemail").val(),
                name: $("#name").val(),
                rss: $("#rss").val()
            },
            function (data) {
//                $('#getresult').append('<p>Result ' + data.updateOfExisting + ' n=' + data.n + '</p>');
                $('#getresult').append('<p>Result ' + data + '</p>');
            },
            "json");
    }

    function editSubscriber() {
        $.post(rootURL + '/update',
            {
                email: $("#editemail").val(),
                name: $("#editname").val(),
                rss: $("#editrss").val()
            },
            function (data) {
//                $('#getresult').append('<p>Result ' + data.updateOfExisting + ' n=' + data.n + '</p>');
                $('#getresult').append('<p>Result ' + data + '</p>');
            },
            "json");
    }

    function suspendSubscriber(id) {
        $.getJSON(rootURL + '/' + id + '/suspend', function (data) {
            $('#getresult').append('<p>' + id + '</p><p>Result jopa' + '</p>');
        });
    }

</script>

<div class="container-fluid">
    <header class="header clearfix">
        <nav>
            <ul class="nav nav-pills pull-right">
                <li role="presentation" class="active"><a href="../index.html">Home</a></li>
                <li role="presentation"><a href="#">About</a></li>
                <li role="presentation"><a href="#">Contact</a></li>
            </ul>
        </nav>
        <h3 class="text-muted">RSS-2-KINDLE</h3>
    </header>
    <hr/>
    <div class="row">
        <nav class="col-sm-3 col-md-2 d-none d-sm-block bg-light sidebar">
            <ul class="nav nav-pills flex-column">
                <li role="presentation"><a href="profile">My Profile</a></li>
                <li role="presentation" class="active"><a href="#">Subscriber Management</a></li>
                <li role="presentation"><a href="service">Services</a></li>
            </ul>
        </nav>
        <main role="main" class="col-sm-9 col-md-10">
            <ul class="nav nav-tabs" id="operationsTab" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="new-tab" data-toggle="tab" href="#new" role="tab" aria-controls="home" aria-selected="true">New subscriber</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="edit-tab" data-toggle="tab" href="#edit" role="tab" aria-controls="profile" aria-selected="false">Edit subscribers</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="remove-tab" data-toggle="tab" href="#remove" role="tab" aria-controls="contact" aria-selected="false">Remove subscribers</a>
                </li>
            </ul>
            <div class="tab-content" id="operationsTabContent">
                <div class="tab-pane fade active" id="new" role="tabpanel" aria-labelledby="new-tab">
                    <h3>Add new subscriber</h3>
                    <form method="POST" id="new_subscr_form" action="">
                        <div class="input-group">
                            <label for="newemail">Email</label>
                            <p><input type="email" id="newemail" required class="form-control"/></p>
                            <label for="name">Name</label>
                            <p><input type="text" id="name" required class="form-control"/></p>
                            <label for="rss">RSS</label>
                            <p><input type="url" id="rss" required class="form-control"/></p>
                            <label for="starttime">Start date</label>
                            <p><input type="date" id="starttime" class="form-control"/></p>
                            <input type="submit" value="Create" class="btn btn-default"/>
                        </div>
                    </form>
                </div>
                <div class="tab-pane fade" id="edit" role="tabpanel" aria-labelledby="edit-tab">
                    <h3>Edit subscriber</h3>
                    <form method="POST" id="edit_subscr_form" action="">
                        <div class="input-group">
                            <label for="editemail">Email</label>
                            <p><input type="email" id="editemail" readonly class="form-control"/><p/>
                            <label for="editname">Name</label>
                            <p><input type="text" id="editname" required class="form-control"/><p/>
                            <label for="editrss">RSS</label>
                            <p><input type="url" id="editrss" required class="form-control"/><p/>
                            <p><input type="submit" value="Apply" class="btn btn-default"/></p>
                        </div>
                    </form>
                </div>
                <div class="tab-pane fade" id="remove" role="tabpanel" aria-labelledby="remove-tab">
                    <h3>Remove subscriber</h3>
                    <form method="GET" id="remove_subscr_form" action="">
                        <label for="removeemail">Enter email of subscriber</label>
                        <div class="input-group">
                            <input type="email" id="removeemail" required class="form-control"/>
                            <span class="input-group-btn">
                                <input type="submit" value="Remove" class="btn btn-default"/>
                            </span>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

</div>
<%--
<div class="container" id="forms">
    <div class="row" id="forms_row">

        <div class="col-md-3" id="forms_aside">
            <div class="list-group">
                <button type="button" class="list-group-item" id="getsubscr">Edit subscriber</button>
                <button type="button" class="list-group-item" id="newsubscr">New subscriber</button>
                <button type="button" class="list-group-item" id="removesubscr">Remove subsciber</button>
                <button type="button" class="list-group-item" id="suspendsubscr">Suspend/resume subsciber</button>
            </div>
        </div>

        <article>
            <div class="col-md-3" id="forms_col">
                <section id="getsubscrview" hidden>
                    <h3>Get subscriber</h3>
                    <form method="GET" id="get_subscr_form" action="">
                        <label for="email">Enter email of subscriber</label>
                        <div class="input-group">
                            <input type="email" id="email" required class="form-control"/>
                            <span class="input-group-btn">
                                <input type="submit" value="Fetch" class="btn btn-default"/>
                            </span>
                        </div>
                    </form>
                </section>
                <section id="editsubscrview" hidden>
                    <h3>Edit subscriber</h3>
                    <form method="POST" id="edit_subscr_form" action="">
                        <div class="input-group">
                            <label for="editemail">Email</label>
                            <p><input type="email" id="editemail" readonly class="form-control"/><p/>
                            <label for="editname">Name</label>
                            <p><input type="text" id="editname" required class="form-control"/><p/>
                            <label for="editrss">RSS</label>
                            <p><input type="url" id="editrss" required class="form-control"/><p/>
                            <p><input type="submit" value="Apply" class="btn btn-default"/></p>
                        </div>
                    </form>
                </section>
                <section id="newsubscrview" hidden>
                    <h3>Add new subscriber</h3>
                    <form method="POST" id="new_subscr_form" action="">
                        <div class="input-group">
                            <label for="newemail">Email</label>
                            <p><input type="email" id="newemail" required class="form-control"/></p>
                            <label for="name">Name</label>
                            <p><input type="text" id="name" required class="form-control"/></p>
                            <label for="rss">RSS</label>
                            <p><input type="url" id="rss" required class="form-control"/></p>
                            <label for="starttime">Start date</label>
                            <p><input type="date" id="starttime" class="form-control"/></p>
                            <input type="submit" value="Create" class="btn btn-default"/>
                        </div>
                    </form>
                </section>
                <section id="removesubscrview" hidden>
                    <h3>Remove subscriber</h3>
                    <form method="GET" id="remove_subscr_form" action="">
                        <label for="removeemail">Enter email of subscriber</label>
                        <div class="input-group">
                            <input type="email" id="removeemail" required class="form-control"/>
                            <span class="input-group-btn">
                                <input type="submit" value="Remove" class="btn btn-default"/>
                            </span>
                        </div>
                    </form>
                </section>
                <section id="suspendsubscrview" hidden>
                    <h3>Suspend or resume subscriber</h3>
                    <form method="GET" id="suspend_subscr_form" action="">
                        <label for="suspendemail">Enter email of subscriber</label>
                        <div class="input-group">
                            <input type="email" id="suspendemail" required class="form-control"/>
                            <div class="input-group-btn">
                                <button type="submit" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Action <span class="caret"></span></button>
                                <ul class="dropdown-menu dropdown-menu-right">
                                    <li><a href="#">Suspend</a></li>
                                    <li><a href="#">Resume</a></li>
                                </ul>
                            </div>
                        </div>
                        <!--<p><input type="submit" value="Apply"/></p>-->
                    </form>
                </section>
            </div>

            <div class="col-md-6">
                <div id="getresult" class="table-responsive">

                </div>
                <p id="errorview">Jopa</p>
            </div>
        </article>
    </div>
</div>
--%>

<!--<aside>This aside</aside>-->


<%@include file="footer.jsp"%>
</body>
</html>