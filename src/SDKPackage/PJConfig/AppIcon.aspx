<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AppIcon.aspx.cs" Inherits="SDKPackage.PJConfig.AppIcon" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class ="col-md-8">
            <div class="form-horizontal">
                <button class="btn btn-primary" data-toggle="modal" data-target="#addIcon">上传图标组</button>
                <button class="btn btn-primary" data-toggle="modal" data-target="#composeIcon">合成图标组</button>
                <asp:Label ID="MessageLabel" runat="server" CssClass="" Text=""></asp:Label>
            </div>
            <div class="modal fade" id="addIcon" tabindex="-1" role="dialog" aria-labelledby="addIconLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×
                            </button>
                            <h2 class="modal-title" id="addIconLabel">
                            上传图标组
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
                                    <h4 class="col-md-5 control-label">drawable(48px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">drawable-ldpi(36px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload36" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">drawable-mdpi(48px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload48" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">drawable-hdpi(72px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload72" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">drawable-xhdpi(96px)</h4>
                                     <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload96" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">drawable-xxhdpi(144px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload144" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">drawable-xxhdpi(144px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload192" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-5 control-label">512(512px)</h4>
                                    <div class="col-md-7">
                                        <asp:FileUpload ID="FileUpload512" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">关闭
                            </button>
                            <asp:Button ID="ButtonAddIcon" runat="server" class="btn btn-primary"  Text="保存" OnClick="ButtonAddIcon_Click"/>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal fade" id="composeIcon" tabindex="-1" role="dialog" aria-labelledby="composeIconLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×
                            </button>
                            <h2 class="modal-title" id="composeIconLabel">
                            自动生成图标组
                            </h2>
                        </div>
                        <div class="modal-body">
                            <div class="form-horizontal">
                                <div class="form-group">
                                    <h4 class="col-md-4 control-label">图标组名称</h4>
                                    <div class="col-md-8">
                                        <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control col-md-12"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-4 control-label">选择图标母板</h4>
                                    <div class="col-md-8">
                                        <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-control" DataSourceID="SqlDataSourceIcon" DataTextField="iconName" DataValueField="iconName"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <h4 class="col-md-4 control-label">选择图标角标</h4>
                                    <div class="col-md-8">
                                        <asp:FileUpload ID="SSFileUpload" runat="server" CssClass="form-control"/>
                                    </div>
                                    
                                </div>
                                <div class="form-group">
                                    <hr />
                                    <h4>如果角标没有预留完整图标空间，只提供了图标内容，需要进行手动尺寸匹配。手动匹配图标强制位置在右下位置</h4>
                                        <h4 class="col-md-4 control-label">选择匹配尺寸</h4>
                                    <div class="col-md-8">
                                        <asp:DropDownList ID="SizeDropDownList" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="0">自动匹配</asp:ListItem>
                                            <asp:ListItem Value="512">512X512</asp:ListItem>
                                            <asp:ListItem Value="144">144X144</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">关闭
                            </button>
                            <asp:Button ID="ButtonComposeIcon" runat="server" class="btn btn-primary"  Text="合成" OnClick="ButtonComposeIcon_Click"/>
                        </div>
                    </div>
                </div>
            </div>

            <hr />
            <asp:ListView ID="ListView1" runat="server" DataKeyNames="Id" DataSourceID="SqlDataSourceIcon">
                <EmptyDataTemplate>
                    <table runat="server" style="">
                        <tr>
                            <td>没有图标</td>
                        </tr>
                    </table>
                </EmptyDataTemplate>

                <ItemTemplate>
                    <tr style="">
                        <td>
                            <h4><%# Eval("iconName") %></h4>
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable-ldpi/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable-mdpi/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable-hdpi/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable-xhdpi/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable-xxhdpi/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/drawable-xxxhdpi/app_icon.png' class="img-rounded" />
                        </td>
                        <td>
                            <img src='/icon/<%# Eval("iconName") %>/512/app_icon.png' class="img-rounded" height="144" width="144" />
                        </td>
                    </tr>
                </ItemTemplate>
                <LayoutTemplate>
                                <table id="itemPlaceholderContainer" runat="server" class="table table-hover">
                                    <tr runat="server" style="">
                                        <th>名称</th>
                                        <th>drawable(48px)</th>
                                        <th>drawable-ldpi(36px)</th>
                                        <th>drawable-mdpi(48px)</th>
                                        <th>drawable-hdpi(72px)</th>
                                        <th>drawable-xhdpi(96px)</th>
                                        <th>drawable-xxhdpi(144px)</th>
                                        <th>drawable-xxxhdpi(192px)</th>
                                        <th>512(512px)</th>
                                    </tr>
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                </LayoutTemplate>
            </asp:ListView>
            <asp:SqlDataSource ID="SqlDataSourceIcon" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getIcon" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
            
        </div>
    </div>
</asp:Content>
