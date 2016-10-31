<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IconTool.aspx.cs" Inherits="SDKPackage.PJConfig.IconTool" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="form-horizontal">
        <div class="form-group">
            <h4 class="col-md-2 control-label">图标组名称</h4>
            <div class="col-md-10">
                <asp:TextBox ID="IconNameTextBox" runat="server" CssClass="form-control col-md-12"></asp:TextBox>
            </div>
        </div>
        <div class="form-group">
            <h4 class="col-md-2 control-label">选择图标母板</h4>
            <div class="col-md-10">
                <asp:DropDownList ID="DropDownListMaster" runat="server" CssClass="form-control" DataSourceID="SqlDataSourceIcons" DataTextField="iconName" DataValueField="iconName"></asp:DropDownList>
                <asp:SqlDataSource ID="SqlDataSourceIcons" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getIcon" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
            </div>
        </div>
        <div class="form-group">
            <h4 class="col-md-2 control-label">选择图标脚标</h4>
            <div class="col-md-10">
                <asp:DropDownList ID="DropDownListSS" runat="server" CssClass="form-control"  DataSourceID="SqlDataSourceIcons" DataTextField="iconName" DataValueField="iconName"></asp:DropDownList>
            </div>
        </div>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-10">
                <asp:Button ID="ButtonCreateIcon" runat="server" Text="Button" OnClick="ButtonCreateIcon_Click" CssClass="btn btn-default"/>
            </div>
        </div>
    </div>
    
</asp:Content>
