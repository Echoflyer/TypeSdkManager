<%@ Page Title="游戏列表" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Games.aspx.cs" Inherits="SDKPackage.PJConfig.Games" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <hr />
    <div class="row">
    <asp:ListView ID="ListView1" runat="server" DataKeyNames="Id" DataSourceID="SqlDataSourceGames">
        <AlternatingItemTemplate>
            <div class="container">
                    <div class="col-md-4">
                        <img src='<%# Eval("GamePic") %>' class="img-rounded" width="200" height="200" />
                    </div>
                    <div class="col-md-8">
                        <h2><%# Eval("GameDisplayName") %></h2>
                        <h4>游戏介绍:</h4>
                        <h4><%# Eval("GameIntroduce") %></h4>
                        <div class="form-inline">
                        <div class="col-md-4">
                            <a href=<%# Eval("GameWebSite") %> >官网地址</a>
                        </div>
                        <div class="col-md-4">
                            <a href='GameConfig.aspx?Id=<%# Eval("Id") %>' >修改信息</a>
                        </div>
                        <div class="col-md-4">
                            <a href='GamesVersionAdd.aspx?gameName=<%# Eval("GameName") %>' >上传新版本</a>
                        </div>
                        </div>
                </div>
            </div>
        </AlternatingItemTemplate>
        <EmptyDataTemplate>
            <span>未返回数据。</span>
        </EmptyDataTemplate>
        <ItemTemplate>
            <div class="container">
                    <div class="col-md-4">
                        <img src='<%# Eval("GamePic") %>' class="img-rounded" width="200" height="200" />
                    </div>
                    <div class="col-md-8">
                        <h2><%# Eval("GameDisplayName") %></h2>
                        <h4>游戏介绍:</h4>
                        <h4><%# Eval("GameIntroduce") %></h4>
                        <div class="col-md-4">
                            <a href=<%# Eval("GameWebSite") %> >官网地址</a>
                        </div>
                        <div class="col-md-4">
                            <a href='GameConfig.aspx?Id=<%# Eval("Id") %>' >修改信息</a>
                        </div>
                        <div class="col-md-4">
                            <a href='GamesVersionAdd.aspx?gameName=<%# Eval("GameName") %>' >上传新版本</a>
                        </div>
                    </div>
            </div>

        </ItemTemplate>
        <LayoutTemplate>
            <div id="itemPlaceholderContainer" runat="server" style="">
                <span runat="server" id="itemPlaceholder" />
            </div>
            <div style="">
            </div>
        </LayoutTemplate>
    </asp:ListView>
    <asp:SqlDataSource ID="SqlDataSourceGames" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getGamesInfo" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
    </div>
</asp:Content>
