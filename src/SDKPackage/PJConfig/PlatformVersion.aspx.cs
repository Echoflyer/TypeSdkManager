using SDKPackage.Facade;
using SDKPackage.Kernel;
using SDKPackage.Utils;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SDKPackage.PJConfig
{
    public partial class PlatformVersion : System.Web.UI.Page
    {
        //protected string id = GameRequest.GetQueryString("id");
        //protected string myversionid = GameRequest.GetQueryString("myversionid");
        //protected string systemname = GameRequest.GetQueryString("systemname");
        NativeWebFacade aideNativeWebFacade = new NativeWebFacade();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ButtonAddPlatformVersion_Click(object sender, EventArgs e)
        {
            this.LabelMessage.Text = "";
            string platformid = this.DropDownListPlatform.SelectedValue;
            string sqlQuery = string.Format(@"select platformName from sdk_DefaultPlatform where id={0}", platformid);
            string platformName = aideNativeWebFacade.GetScalarBySql(sqlQuery);
            string platformVersion = CtrlHelper.GetText(TextBoxVersion);
            string SDKPackageDir = ConfigurationManager.AppSettings["SDKPackageDir"];
            SDKPackageDir = SDKPackageDir + "SDK\\Channel_SDK\\" + platformName + "\\" + platformVersion + "\\";
            if (!System.IO.Directory.Exists(SDKPackageDir))
            {
                Response.Write("<script>alert('渠道版本创建失败\\r\\n该渠道版本文件夹不存在！')</script>");
                //this.LabelMessage.Text = "渠道配置文件夹尚未创建！";
                return;
            }
            string systemid = this.DropDownListSystem.SelectedValue;
            string username = Context.User.Identity.Name;
            Message umsg = aideNativeWebFacade.AddMyVersion(platformVersion, username, platformid, systemid);
            if (umsg.Success)
            {
                this.ListView1.DataBind();
                return;
            }
            Response.Write("<script>alert('" + umsg.Content + "')</script>");
            //this.LabelMessage.Text = umsg.Content;
        }
    }
}