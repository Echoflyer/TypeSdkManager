<%@ Page Title="上传游戏版本" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GamesVersionAdd.aspx.cs" Inherits="SDKPackage.GameConfig.GamesVersionAdd" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <hr />
    <div class="col-md-8">
        <div class="form-horizontal">
            <div class="form-group">
                <h4 class="col-md-2 control-label">上传项目</h4>
                <div class="col-md-10">
                    <asp:FileUpload ID="GameVersionFileUpload" runat="server" />
                </div>
            </div>
            <div class="form-group">
                <h4 class="col-md-2 control-lable">标签</h4>
                <div class="col-md-10">
                    <asp:TextBox ID="TextBoxVersionLabel" runat="server"></asp:TextBox>
                </div>
            </div>
            <div class="form-group">
                <asp:Button ID="saveButton" runat="server" Text="保存" CssClass="col-md-offset-2 btn btn-primary" OnClick="saveButton_Click" />
            </div>
        </div>
        <asp:Label ID="LogLabel" runat="server" Text="" ForeColor="Red"></asp:Label>
    </div>
    <div class="col-md-4">
            <p class="lead">操作说明</p>

            <p>1. 将项目目录改名为Game,并压缩为Game.zip文件。</p>
            <p>2. 使用具有开发者权限的帐号登录<a href="../GameConfig/GamesVersionAdd.aspx">游戏版本上传页面</a>。</p>
            <p>3. 选择需要上传的Game.zip文</p>
            <p>4. 点击《保存》按钮开始上传。</p>
            <p>5. 上传过程中会对包进行分析，需要一定时间请耐心等待。</p>
            <p>6. 如提示上传成功，可至<a href="../PJPackage/Package.aspx">打包页面</a>对最新版本打包。</p>
    </div>
</asp:Content>
