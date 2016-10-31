using SDKPackage.Facade;
using SDKPackage.Utils;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SDKPackage.PJPackage
{
    public partial class SelectGameVersionList : System.Web.UI.Page
    {
        protected string platform = GameRequest.GetQueryString("platform");
        protected string gameId = GameRequest.GetQueryString("gameid");
        protected string gameName = GameRequest.GetQueryString("gameName");
        protected string gameDisplayName = GameRequest.GetQueryString("gameDisplayName");
        protected string gamenamespell = GameRequest.GetQueryString("gamenamespell");
        protected string taskid = GameRequest.GetQueryString("taskid");
        protected bool isBack = false;
        NativeWebFacade aideNativeWebFacade = new NativeWebFacade();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(taskid))
                isBack = true;
            if (Cache["Roleid"] == null || Cache["Roleid"].ToString() == "")
            {
                BindingCache();
            }
        }

        private void BindingCache()
        {
            string sql = string.Format(@"  select * from [AspNetUserRoles] r inner join AspNetUsers u on r.UserId=u.Id and u.UserName='{0}' and RoleId in (2,3)", Context.User.Identity.Name);
            DataSet ds = aideNativeWebFacade.GetDataSetBySql(sql);
            if (ds.Tables[0].Rows.Count > 0)
                Cache["Roleid"] = "0";
            else
                Cache["Roleid"] = "1";
        }

        protected void GameVersionList_ItemCommand(object sender, ListViewCommandEventArgs e)
        {
            if (e.CommandName == "del")
            {
                string[] arr = e.CommandArgument.ToString().Split(',');
                string id = arr[0];
                string SDKPackageDir = "";//SDKAndroidPackageGameFile
                if (platform == "Android")
                {
                    SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKAndroidPackageGameFile"] + gameName + "\\" + arr[1];
                }
                else
                {
                    string[] split = new string[] { ".zip_" };
                    SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKIOSPackageGameFile"] + gamenamespell + "\\" + arr[1].Split(split, StringSplitOptions.None)[1];
                }
                if (System.IO.Directory.Exists(SDKPackageDir))
                {
                    System.IO.Directory.Delete(SDKPackageDir, true);
                }
                string sql = string.Format(@"delete from sdk_UploadPackageInfo where id={0}", id);
                aideNativeWebFacade.ExecuteSql(sql);
                this.GameVersionList.DataBind();
            }
        }
    }
}