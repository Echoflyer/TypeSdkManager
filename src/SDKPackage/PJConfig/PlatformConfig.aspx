<%@ Page Title="渠道参数配置" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlatformConfig.aspx.cs" Inherits="SDKPackage.PJConfig.PlatformConfig" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-md-12">
            <div class="form-horizontal">
                <asp:ListView ID="ListView1" runat="server" DataKeyNames="Id" DataSourceID="SqlDataSourcePlatform">
                    <AlternatingItemTemplate>
                        <div class="form-group">
                            <h5 class="col-md-2">渠道编号:</h5><h5 class="col-md-4"><%# Eval("PlatformName") %></h5>
                            <h5 class="col-md-2">渠道名称:</h5><h5 class="col-md-4"><%# Eval("PlatformDisplayName") %></h5>
                            <h5 class="col-md-2">SDK版本:</h5><h5 class="col-md-4"><%# Eval("SdkVersion") %></h5>
                            <h5 class="col-md-2">接入状态:</h5><h5 class="col-md-4"><%# Eval("PlatformStatusName") %></h5>
                        </div>
                    </AlternatingItemTemplate>
       
                    <EmptyDataTemplate>
                        <span>没有配置数据。</span>
                    </EmptyDataTemplate>
        
                    <ItemTemplate>
                        <div class="form-group">
                            <h5 class="col-md-2">渠道编号:</h5><h5 class="col-md-10"><%# Eval("PlatformName") %></h5>
                            <h5 class="col-md-2">渠道名称:</h5><h5 class="col-md-10"><%# Eval("PlatformDisplayName") %></h5>
                            <h5 class="col-md-2">SDK版本:</h5><h5 class="col-md-10"><%# Eval("SdkVersion") %></h5>
                            <h5 class="col-md-2">接入状态:</h5><h5 class="col-md-10"><%# Eval("PlatformStatusName") %></h5>
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
                <asp:SqlDataSource ID="SqlDataSourcePlatform" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getPlatform" SelectCommandType="StoredProcedure">
                    <SelectParameters>
                        <asp:QueryStringParameter Name="PlatformName" QueryStringField="id" Type="String" />
                    </SelectParameters>
                </asp:SqlDataSource>
            </div>
            <hr />

            <div class="form-inline">
                <div class="form-group">
                    <h4 class="control-label">游戏名称</h4>
                </div>
                <div class="form-group">
                    <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-control" DataSourceID="SqlDataSourceGames" DataTextField="GameDisplayName" DataValueField="GameName" AutoPostBack="True"></asp:DropDownList>
                </div>
                <asp:SqlDataSource ID="SqlDataSourceGames" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getGames" SelectCommandType="StoredProcedure"></asp:SqlDataSource>
            </div>
            <hr />
            <ul id="myTab" class="nav nav-tabs">
                <li class="active">
                    <a href="#parameter" data-toggle="tab">游戏参数</a>
                </li>
                <li><a href="#icon" data-toggle="tab">游戏图标</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div class="tab-pane fade in active" id="parameter">
                    <asp:ListView ID="ListView2" runat="server" DataKeyNames="Id" DataSourceID="SqlDataSourcePlatformConfig" InsertItemPosition="LastItem">
                        <AlternatingItemTemplate>
                            <tr>
                                <td>
                                    <asp:Button ID="EditButton" runat="server" CommandName="Edit" class="btn btn-default btn-sm" Text="编辑" />
                                </td>
                                <td>
                                    <asp:Label ID="SDKKeyLabel" runat="server" Text='<%# Eval("SDKKey") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="ExplainLabel" runat="server" Text='<%# Eval("Explain") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="StringValueLabel" runat="server" Text='<%# Eval("StringValue") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isCPSettingCheckBox" runat="server" Checked='<%# Eval("isCPSetting") %>' Enabled="false" />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isBuildingCheckBox" runat="server" Checked='<%# Eval("isBuilding") %>' Enabled="false" />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isServerCheckBox" runat="server" Checked='<%# Eval("isServer") %>' Enabled="false" />
                                </td>
                                <td>
                                    <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" class="btn btn-default btn-sm" Text="删除" />
                                </td>
                            </tr>
                        </AlternatingItemTemplate>
                        <EditItemTemplate>
                            <tr>
                                <td>
                                    <asp:Button ID="UpdateButton" runat="server" CommandName="Update" class="btn btn-success btn-sm" Text="更新" />
                                </td>
                                <td>
                                    <asp:Label ID="SDKKeyLabel" runat="server" Width="100%" Text='<%# Eval("SDKKey") %>' />
                                </td>
                                <td>
                                    <asp:TextBox ID="ExplainTextBox" runat="server" Width="100%" Text='<%# Bind("Explain") %>' />
                                </td>
                                <td>
                                    <asp:TextBox ID="StringValueTextBox" runat="server" Width="100%" Text='<%# Bind("StringValue") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isCPSettingCheckBox" runat="server" Checked='<%# Bind("isCPSetting") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isBuildingCheckBox" runat="server" Checked='<%# Bind("isBuilding") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isServerCheckBox" runat="server" Checked='<%# Bind("isServer") %>' />
                                </td>
                                <td>
                                    <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" class="btn btn-warning btn-sm" Text="取消" />
                                </td>
                            </tr>
                        </EditItemTemplate>
                        <EmptyDataTemplate>
                            <table runat="server">
                                <tr>
                                    <td>未返回数据。</td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>
                        <InsertItemTemplate>
                            <tr>
                                <td>
                                    <asp:Button ID="InsertButton" runat="server" CommandName="Insert" class="btn btn-default btn-sm" Text="插入" />
                                </td>
                                <td>
                                    <asp:TextBox ID="SDKKeyTextBox" runat="server" CssClass="form-control" Text='<%# Bind("SDKKey") %>' />
                                </td>
                                <td>
                                    <asp:TextBox ID="ExplainTextBox" runat="server" CssClass="form-control" Text='<%# Bind("Explain") %>' />
                                </td>
                                <td>
                                    <asp:TextBox ID="StringValueTextBox" runat="server" CssClass="form-control"  Text='<%# Bind("StringValue") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isCPSettingCheckBox" runat="server" Checked='<%# Bind("isCPSetting") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isBuildingCheckBox" runat="server" Checked='<%# Bind("isBuilding") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isServerCheckBox" runat="server" Checked='<%# Bind("isServer") %>' />
                                </td>
                                <td>
                                    <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" class="btn btn-default btn-sm" Text="清除" />
                                </td>
                            </tr>
                        </InsertItemTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:Button ID="EditButton" runat="server" CommandName="Edit" class="btn btn-default btn-sm" Text="编辑" />
                                </td>
                                <td>
                                    <asp:Label ID="SDKKeyLabel" runat="server" Text='<%# Eval("SDKKey") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="ExplainLabel" runat="server" Text='<%# Eval("Explain") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="StringValueLabel" runat="server" Text='<%# Eval("StringValue") %>' />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isCPSettingCheckBox" runat="server" Checked='<%# Eval("isCPSetting") %>' Enabled="false" />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isBuildingCheckBox" runat="server" Checked='<%# Eval("isBuilding") %>' Enabled="false" />
                                </td>
                                <td>
                                    <asp:CheckBox ID="isServerCheckBox" runat="server" Checked='<%# Eval("isServer") %>' Enabled="false" />
                                </td>
                                <td>
                                    <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" class="btn btn-default btn-sm" Text="删除" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <LayoutTemplate>
                            <table id="itemPlaceholderContainer" runat="server" class="table table-hover">
                                <thead>
                                    <tr runat="server">
                                        <th runat="server">编辑</th>
                                        <th runat="server">参数名</th>
                                        <th runat="server">说明</th>
                                        <th runat="server">参数值</th>
                                        <th runat="server">CPSetting</th>
                                        <th runat="server">编译参数</th>
                                        <th runat="server">服务参数</th>
                                        <th runat="server">删除</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </tbody>
                            </table>
                        </LayoutTemplate>
                    </asp:ListView>
                    <asp:SqlDataSource ID="SqlDataSourcePlatformConfig" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" DeleteCommand="DELETE FROM [sdk_PlatformConfig] WHERE [Id] = @Id" InsertCommand="INSERT INTO [sdk_PlatformConfig] ([GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (@GameName, @PlatformName, @SDKKey, @Explain, @StringValue, @isCPSetting, @isBuilding, @isServer)" SelectCommand="SELECT * FROM [sdk_PlatformConfig] WHERE (([GameName] = @GameName) AND ([PlatformName] = @PlatformName))" UpdateCommand="UPDATE [sdk_PlatformConfig] SET [Explain] = @Explain, [StringValue] = @StringValue, [isCPSetting] = @isCPSetting, [isBuilding] = @isBuilding, [isServer] = @isServer WHERE [Id] = @Id">
                        <DeleteParameters>
                            <asp:Parameter Name="Id" Type="Int32" />
                        </DeleteParameters>
                        <InsertParameters>
                            <asp:ControlParameter ControlID="DropDownList1" Name="GameName" PropertyName="SelectedValue" Type="String" />
                            <asp:QueryStringParameter Name="PlatformName" QueryStringField="id" Type="String" />
                            <asp:Parameter Name="SDKKey" Type="String" />
                            <asp:Parameter Name="Explain" Type="String" />
                            <asp:Parameter Name="StringValue" Type="String" />
                            <asp:Parameter Name="isCPSetting" Type="Boolean" />
                            <asp:Parameter Name="isBuilding" Type="Boolean" />
                            <asp:Parameter Name="isServer" Type="Boolean" />
                        </InsertParameters>
                        <SelectParameters>
                            <asp:ControlParameter ControlID="DropDownList1" Name="GameName" PropertyName="SelectedValue" Type="String" />
                            <asp:QueryStringParameter Name="PlatformName" QueryStringField="id" Type="String" />
                        </SelectParameters>
                        <UpdateParameters>
                            <asp:Parameter Name="Explain" Type="String" />
                            <asp:Parameter Name="StringValue" Type="String" />
                            <asp:Parameter Name="isCPSetting" Type="Boolean" />
                            <asp:Parameter Name="isBuilding" Type="Boolean" />
                            <asp:Parameter Name="isServer" Type="Boolean" />
                            <asp:Parameter Name="Id" Type="Int32" />
                        </UpdateParameters>
                    </asp:SqlDataSource>

                    <hr />
                    <button class="btn btn-primary btn-lg" data-toggle="modal" data-target="#createConfigFile">
                        保存至项目配置文件
                    </button>

                    <div class="modal fade" id="createConfigFile" tabindex="-1" role="dialog" aria-labelledby="createConfigFileLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×
                                    </button>
                                    <h4 class="modal-title" id="createConfigFileLabel">
                                    确认保存操作
                                    </h4>
                                </div>
                                <div class="modal-body">
                                    保存操作将覆盖项目内现有配置文件，是否确认需要覆盖保存。
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">取消
                                    </button>
                                    <asp:Button ID="ButtonCreateConfigFile" runat="server" class="btn btn-primary" OnClick="ButtonCreateConfigFile_Click" Text="确认保存" />
                                </div>
                            </div>
                        </div>
                    </div>
           
                    <asp:SqlDataSource ID="SqlDataSourceCpSetting" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getPlatformConfigCPSetting" SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="DropDownList1" Name="GameName" PropertyName="SelectedValue" Type="String" />
                            <asp:QueryStringParameter Name="PlatformName" QueryStringField="id" Type="String" />
                        </SelectParameters>
                    </asp:SqlDataSource>

                    <br />
                    <asp:Label ID="Label2" runat="server" Text=""></asp:Label>
                    <asp:SqlDataSource ID="SqlDataSourceLocal" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getPlatformConfigLocal" SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="DropDownList1" Name="GameName" PropertyName="SelectedValue" Type="String" />
                            <asp:QueryStringParameter Name="PlatformName" QueryStringField="id" Type="String" />
                        </SelectParameters>
                    </asp:SqlDataSource>


                    
                    
                </div>
                <div class="tab-pane fade" id="icon">
                    <h4>当前图标</h4>
                    <asp:ListView ID="ListView3" runat="server" DataSourceID="SqlDataSourceGamePlatformIcon">
                        <AlternatingItemTemplate>
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
                            </tr>
                        </AlternatingItemTemplate>
                        
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
                                </tr>
                                    <tr id="itemPlaceholder" runat="server">
                                </tr>
                            </table>
                        </LayoutTemplate>
                    </asp:ListView>
                    <asp:SqlDataSource ID="SqlDataSourceGamePlatformIcon" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="sdk_getGamePlatformIcon" SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="DropDownList1" Name="GameName" PropertyName="SelectedValue" Type="String" />
                            <asp:QueryStringParameter Name="PlatformName" QueryStringField="id" Type="String" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                    <hr />                    
                </div>
            </div>
        </div>
    </div>
</asp:Content>
