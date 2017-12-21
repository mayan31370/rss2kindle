<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>RSS-2-Kindle Service</title>
    <meta name="viewport" content="width = device-width, initial-scale = 1.0">

    <!-- JQuery -->
    <script src="js/jquery-3.1.1.js"></script>

    <!-- Bootstrap -->
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="bootstrap/css/bootstrap-theme.min.css" rel="stylesheet">
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="bootstrap/js/bootstrap.min.js"></script>
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->

    <!-- Custom css -->
    <%--<link href="css/sticky-footer.css" rel="stylesheet">--%>
    <link href="css/signin.css" rel="stylesheet">
    <link href="css/landing-theme.css" rel="stylesheet">

</head>
<body>

<div class="container">
    <div class="header clearfix">
        <nav>
            <ul class="nav nav-pills pull-right">
                <li role="presentation" class="active"><a href="index.html">Home</a></li>
                <li role="presentation"><a href="#">About</a></li>
                <li role="presentation"><a href="#">Contact</a></li>
            </ul>
        </nav>
        <h3 class="text-muted">RSS-2-KINDLE</h3>
    </div>

    <div id="signup" class="jumbotron">
        <form class="form-signin" action="<c:url value='join'/>" method="post" autocomplete="off">
            <h2 class="form-signin-heading">Please sign up</h2>
            <label for="newUsername" class="sr-only">Username</label>
            <input type="email" id="newUsername" class="form-control" placeholder="Username" required autofocus>
            <label for="newEmail" class="sr-only">E-mail</label>
            <input type="email" id="newEmail" class="form-control" placeholder="e-mail" required>
            <label for="newPassword" class="sr-only">Password</label>
            <input type="password" id="newPassword" class="form-control" placeholder="Password" required>
            <label for="verifyPassword" class="sr-only">Verify Password</label>
            <input type="password" id="verifyPassword" class="form-control" placeholder="Verify password" required>
            <input type="hidden" name="<c:out value="${_csrf.parameterName}"/>" value="<c:out value="${_csrf.token}"/>"/>

            <button class="btn btn-lg btn-success btn-block" type="submit">Sign up</button>
        </form>

    </div> <!-- /container -->

    <footer class="footer">
        <p>&copy; Created by Eurohlam. 2017</p>
    </footer>
</div> <!-- /container -->

</body>

</html>
