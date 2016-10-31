<%@ Page Title="忘记了密码" Language="C#" AutoEventWireup="true" CodeBehind="Forgot.aspx.cs" Inherits="SDKPackage.Account.ForgotPassword" Async="true" %>

<!DOCTYPE html>
<html class="bootstrap-admin-vertical-centered">
<head runat="server">
    <title><%: Page.Title %></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap -->
    <link rel="stylesheet" media="screen" href="/css/bootstrap.min.css">
    <link rel="stylesheet" media="screen" href="/css/bootstrap-theme.min.css">

    <!-- Bootstrap Admin Theme -->
    <link rel="stylesheet" media="screen" href="/css/bootstrap-admin-theme.css">

    <!-- Custom styles -->
    <style type="text/css">
        .alert {
            margin: 0 auto 20px;
        }
    </style>

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
           <script type="text/javascript" src="js/html5shiv.js"></script>
           <script type="text/javascript" src="js/respond.min.js"></script>
        <![endif]-->
</head>
<body class="bootstrap-admin-without-padding">
    <div class="container">
        <div class="row">
            <div class="col-lg-12">
                <asp:PlaceHolder runat="server" ID="ErrorMessage" Visible="false">
                    <div class="alert alert-info">
                        <a class="close" data-dismiss="alert" href="#">&times;</a>
                        <asp:Literal runat="server" ID="FailureText" />
                    </div>
                </asp:PlaceHolder>
                <form class="bootstrap-admin-login-form" runat="server">
                    <h1>找回密码</h1>
                    <div class="form-group">
                        <asp:TextBox runat="server" ID="Email" CssClass="form-control" TextMode="Email" placeholder="E-mail" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="Email"
                            CssClass="text-danger" ErrorMessage="“电子邮件”字段是必填字段。" />
                    </div>
                    <div class="form-group">
                        <asp:Button runat="server" OnClick="Forgot" Text="提交" CssClass="btn btn-primary btn-block btn-lg" ID="ButtonForgot" />
                    </div>
                </form>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="/js/jquery-2.0.3.min.js"></script>
    <script type="text/javascript" src="/js/bootstrap.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $("#MainContent_ButtonForgot").click(function () {
                $(this).val("邮件发送中");
            });
            $(".text-danger").change(function () {
                $("#MainContent_ButtonForgot").val("提交");
            });
        })
        $(function () {
            // Setting focus
            $('input[name="email"]').focus();
            // Setting width of the alert box
            var alert = $('.alert');
            var formWidth = $('.bootstrap-admin-login-form').innerWidth();
            var alertPadding = parseInt($('.alert').css('padding'));

            if (isNaN(alertPadding)) {
                alertPadding = parseInt($(alert).css('padding-left'));
            }
            $('.alert').width(formWidth - 2 * alertPadding);
        });
    </script>
</body>
</html>
