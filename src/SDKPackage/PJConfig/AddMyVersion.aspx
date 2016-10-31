<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddMyVersion.aspx.cs" Inherits="SDKPackage.PJConfig.AddMyVersion" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href="/Content/bootstrap.css" rel="stylesheet" />
    <title>添加版本</title>    
</head>
<body>
    <form id="form1" runat="server">
        <div class="form-group" style="margin:20px 0 0 20px;">
            <label>请输入版本号:</label>
            <asp:TextBox ID="txtMyVersion" runat="server" placeholder="1.0" required="required" CssClass="form-control" style=" width:250px;"></asp:TextBox>
        </div>
        <div class="form-group" style="margin:20px 0 0 20px;">
            <asp:Button ID="btnAddMyVersion" runat="server" Text="添加" OnClick="btnAddMyVersion_Click" CssClass="col-md-offset-2 btn btn-primary " />
            <asp:Label ID="lblLog" runat="server" Text="" Style="margin-left: 20px; color: #f00"></asp:Label>
        </div>
    </form>
</body>
</html>
