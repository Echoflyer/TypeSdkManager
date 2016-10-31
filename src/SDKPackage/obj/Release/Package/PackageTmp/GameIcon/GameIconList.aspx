<%@ Page Title="图标管理" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="GameIconList.aspx.cs" Inherits="SDKPackage.GameIcon.GameIconList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        function radioUpdate()
        {
            $("#MainContent_SSFileUpload").removeClass("hidden");
            $("#MainContent_DropDownList2").addClass("hidden");
        }
        function radioSelect() {
            $("#MainContent_SSFileUpload").addClass("hidden");
            $("#MainContent_DropDownList2").removeClass("hidden");
        }
    </script>


    <!--上传图标-->
    <div class="modal fade" id="addIcon" tabindex="-1" role="dialog" aria-labelledby="addIconLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        ×</button>
                    <h2 class="modal-title" id="addIconLabel">上传图标组
                    </h2>
                </div>
                <div class="modal-body">
                    <div class="form-horizontal">
                        <div class="form-group">
                            <h4 class="col-md-5 control-label">icon名称</h4>
                            <div class="col-md-7">
                                <asp:TextBox ID="IconNameTextBox" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <h4 class="col-md-5 control-label">drawable(512px)</h4>
                            <div class="col-md-7">
                                <asp:FileUpload ID="FileUpload" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        关闭
                    </button>
                    <asp:Button ID="ButtonAddIcon" runat="server" CssClass="btn btn-primary" Text="保存" OnClick="ButtonAddIcon_Click" />
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12 col-sm-12 col-xs-12">
            <div class="x_panel">
                <div class="x_title">
                    <h2>游戏渠道图标管理</h2>
					<ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                    </ul>
				<div class="clearfix"></div>
                </div>
                <div class="x_content">
                    <div class="form-inline">
                        <div class="form-group">
                            <label class="control-label">游戏名称</label>
                            <asp:DropDownList ID="ddlGameList" runat="server" CssClass="form-control" DataSourceID="SqlDataSourceGames" DataTextField="GameDisplayName" DataValueField="GameName" AutoPostBack="True"></asp:DropDownList>
                        </div>
                        <asp:SqlDataSource ID="SqlDataSourceGames" runat="server" ConnectionString="<%$ ConnectionStrings:DefaultConnection %>" SelectCommand="sdk_getGameList" SelectCommandType="StoredProcedure">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="saveusername" Type="String" Name="UserName" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                        <asp:HiddenField ID="saveusername" runat="server" />
                        <div class="form-group">
                            <label class="control-label">平台</label>
                            <asp:DropDownList ID="DropDownListSystem" runat="server" CssClass="form-control" AutoPostBack="True">
                                <asp:ListItem Text="Android" Value="1" />
                                <asp:ListItem Text="iOS" Value="2" />
                            </asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <a class="btn btn-primary" data-toggle="modal" href="#addIcon">上传图标组</a>
                            <a class="btn btn-primary" onClick="
                new PNotify({
                                  title: '提示',
                                  text: 'TypeSDK免费版本不支持自动合成渠道图标，请购买高级或企业版本。',
                                  type: 'info',
                                  styling: 'bootstrap3',
                                  addclass: 'dark',
                  delay: 5000
                              });" href="#">合成图标组</a>
                            <asp:Label ID="MessageLabel" runat="server" CssClass="" Text=""></asp:Label>
                        </div>
                    </div>
                    <hr />

                    <asp:ListView ID="ListView3" runat="server" DataSourceID="SqlDataSourceGameIcon">
                        <EmptyDataTemplate>
                            <div style="font-size: 20px; color: #f00; margin-top: 20px;">未配置</div>
                        </EmptyDataTemplate>
                        <ItemTemplate>
                            <div class="col-md-3">
                                <div class="thumbnail">
                                    <img data-src="holder.js/150x150?text=<%# Eval("IconName") %>" alt="150x150" style="width: 150px; height: auto;" src="/icon/<%# Eval("GameName") %>/<%# Eval("IconName") %>/app_icon.png"></img>
                                    <label style="text-align:center" class="btn-block"><%# Eval("IconName") %></label>
                                </div>
                            </div>
                        </ItemTemplate>
                        <LayoutTemplate>
                                <tr id="itemPlaceholder" runat="server">
                                </tr>
                        </LayoutTemplate>
                    </asp:ListView>
                    <asp:SqlDataSource ID="SqlDataSourceGameIcon" runat="server" ConnectionString="<%$ ConnectionStrings:DefaultConnection %>" SelectCommand="sdk_getGameIconList_byGameName" SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="ddlGameList" Name="GameName" PropertyName="SelectedValue" Type="String" />
                            <asp:ControlParameter ControlID="DropDownListSystem" Name="SystemID" Type="String" PropertyName="SelectedValue" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
