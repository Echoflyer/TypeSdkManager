<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="SDKPackage.PJPackage.WebForm1" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        function openfile(taskid, createtaskid) {
            //alert(createtaskid); return;
            var str_href = "sdkPackageLog.aspx?taskid=" + taskid + "&createtaskid=" + createtaskid;
            //alert(str_href); return;
            //var str_href = "\\\\192.168.1.6/package_share/output/logs/" + createtaskid + "/" + taskid + ".txt";
            window.open(str_href, '打包日志', 'height=565,width=700,top=20%,left=30%,toolbar=no,menubar=no,scrollbars=no, resizable=no,location=no, status=no');
        }

    </script>
    <div style="padding-left: 100px">
        <asp:Image ID="Image1" runat="server" ImageUrl="~/img/nave6-6.png" />
    </div>
    <hr />
    <div style="margin-left: 130px; float: left; margin-right: 20px;">
        <h4 style="color: #71D0FF">游戏: <%= gameDisplayName %></h4>
    </div>
    <div style="float: left; margin-right: 20px;">
        <h4 style="color: #71D0FF">平台:<%= platform %></h4>
    </div>
    <div style="float: left">
        <h4 style="color: #71D0FF">版本:<%= gameversion %></h4>
    </div>
    <div style="clear: both;"></div>

    <asp:ListView ID="GamePlaceList" runat="server" Style="padding: 0 20px;">
        <AlternatingItemTemplate>
            <tr>
                <td><%#Eval("RecID") %></td>
                <td>
                    <%--<input type="checkbox" value="<%#Eval("RecID") %>" name="cbPlace" disabled="disabled" />--%> <%#Eval("PlatformDisplayName") %></td>

                <td><%#Eval("PlatformName") %></td>

                <td><%# Eval("PackageTaskStatus").ToString()=="0"?"暂未开始":Eval("PackageTaskStatus").ToString()=="1"?"暂未开始":Eval("PackageTaskStatus").ToString()=="2"?"正在打包":Eval("PackageTaskStatus").ToString()=="3"?"<span style=\"color:#338610\">打包成功</span>":"<span style=\"color:#f00\">打包失败</span>" %></td>

                <td><%# Eval("PackageTaskStatus").ToString()=="0"?" ":Eval("PackageTaskStatus").ToString()=="1"?" ":"<a onclick=\"openfile('"+Eval("RecID")+"','"+createtaskid+"');\">详情</a>" %></td>

                <td><%# Eval("PackageTaskStatus").ToString()=="3"?"<a href=\"/package/output/apk/"+gameName+"/"+createtaskid+"/"+Eval("PackageName")+"\">下载</a><a style=\"margin-left:10px;\" href=\"/package/output/apk/"+gameName+"/"+createtaskid+"/"+"us_"+Eval("PackageName")+"\">下载(无签名)</a>":" " %></td>

            </tr>
        </AlternatingItemTemplate>

        <EmptyDataTemplate>
            <table runat="server" style="">
                <tr>
                    <td>当前没有任务。</td>
                </tr>
            </table>
        </EmptyDataTemplate>

        <ItemTemplate>
            <tr>
                <td><%#Eval("RecID") %></td>
                <td>
                    <%--<input type="checkbox" value="<%#Eval("RecID") %>" name="cbPlace" disabled="disabled" />--%> <%#Eval("PlatformDisplayName") %></td>

                <td><%#Eval("PlatformName") %></td>

                <td><%# Eval("PackageTaskStatus").ToString()=="0"?"暂未开始":Eval("PackageTaskStatus").ToString()=="1"?"暂未开始":Eval("PackageTaskStatus").ToString()=="2"?"正在打包":Eval("PackageTaskStatus").ToString()=="3"?"<span style=\"color:#338610\">打包成功</span>":"<span style=\"color:#f00\">打包失败</span>" %></td>

                <td><%# Eval("PackageTaskStatus").ToString()=="0"?" ":Eval("PackageTaskStatus").ToString()=="1"?" ":"<a onclick=\"openfile('"+Eval("RecID")+"','"+createtaskid+"');\">详情</a>" %></td>
                <%--<a onclick=\"openfile("+Eval("RecID")+","+createtaskid+");\">详情</a>--%>

                <td><%# Eval("PackageTaskStatus").ToString()=="3"?"<a href=\"/package/output/apk/"+gameName+"/"+createtaskid+"/"+Eval("PackageName")+"\">下载</a><a style=\"margin-left:10px;\" href=\"/package/output/apk/"+gameName+"/"+createtaskid+"/"+"us_"+Eval("PackageName")+"\">下载(无签名)</a>":" " %></td>

            </tr>
        </ItemTemplate>

        <LayoutTemplate>
            <table id="itemPlaceholderContainer" runat="server" class="table table-hover">
                <caption>渠道列表</caption>
                <thead>
                    <tr runat="server" style="">
                        <th runat="server">任务ID</th>
                        <th runat="server">渠道名称</th>
                        <th runat="server">渠道编号</th>
                        <th runat="server">打包状况</th>
                        <th style="width: 10%">日志</th>
                        <th style="width: 20%">渠道包</th>
                    </tr>
                </thead>
                <tbody>
                    <tr id="itemPlaceholder" runat="server">
                    </tr>
                </tbody>
            </table>
        </LayoutTemplate>
    </asp:ListView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:SdkPackageConnString %>" SelectCommand="">
        <SelectParameters>

        </SelectParameters>
    </asp:SqlDataSource>
    <br />
    <br />
    <asp:Timer ID="Timer1" runat="server" Interval="5000" OnTick="Timer1_Tick"></asp:Timer>
</asp:Content>
