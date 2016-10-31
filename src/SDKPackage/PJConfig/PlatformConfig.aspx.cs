using System;
using System.Text;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SDKPackage.PJConfig
{
    public partial class PlatformConfig : System.Web.UI.Page
    {
        private string PlatformName;
        private string GameName;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] != null)
            {
                PlatformName = Request.QueryString["id"].ToString();
            }
        }

        protected void ButtonCreateConfigFile_Click(object sender, EventArgs e)
        {
            PlatformName = Request.QueryString["id"].ToString();
            GameName = DropDownList1.SelectedValue.ToString();
            try
            {
                CreateCPSettings();
                CreateLocalConfig();
                Label2.Text = "配置文件生成完毕";
            }
            catch (Exception ex)
            {
                Label2.Text = ex.Message.ToString();
            }
        }

        private void CreateCPSettings()
        {
            DataView dvCpSetting = (DataView)SqlDataSourceCpSetting.Select(DataSourceSelectArguments.Empty);
            String jsonCpSetting = ToJson(dvCpSetting);
            //TextBox1.Text = jsonCpSetting;
            String SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKPackageDir"];
            string filePatch = SDKPackageDir + "Config\\" + GameName + "\\" + PlatformName;
            if (!System.IO.Directory.Exists(filePatch))
            {
                System.IO.Directory.CreateDirectory(filePatch);
            }
            String fileCpSetting = filePatch + "\\CPSettings.txt";
            StreamWriter sw = new StreamWriter(fileCpSetting, false, Encoding.UTF8);
            sw.Write(jsonCpSetting);
            sw.Close();
        }

        private void CreateLocalConfig()
        {
            DataView dvLocalConfig = (DataView)SqlDataSourceLocal.Select(DataSourceSelectArguments.Empty);
            String localConfig = ToConfig(dvLocalConfig);
            String SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKPackageDir"];
            string filePatch = SDKPackageDir + "Config\\" + GameName + "\\" + PlatformName;
            if (!System.IO.Directory.Exists(filePatch))
            {
                System.IO.Directory.CreateDirectory(filePatch);
            }
            String fileCpSetting = filePatch + "\\local.properties";
            UTF8Encoding encoding = new UTF8Encoding(false);
            StreamWriter sw = new StreamWriter(fileCpSetting, false, encoding);
            sw.Write(localConfig);
            sw.Close();
        }

        public static string ToJson(DataView dv)
        {
            DataTable dt = dv.Table;
            DataRowCollection drc = dt.Rows;
            StringBuilder jsonString = new StringBuilder();
            jsonString.Append("{\r\n");

            for (int i = 0; i < drc.Count; i++)
            {
                string strKey = drc[i][0].ToString();
                string strValue = drc[i][1].ToString();
                jsonString.Append("\"" + strKey + "\":\"" + strValue + "\",\r\n");
            }
            jsonString.Remove(jsonString.Length - 3, 1);
            jsonString.Append("}");
            return jsonString.ToString();
        }

        public static string ToConfig(DataView dv)
        {
            DataTable dt = dv.Table;
            DataRowCollection drc = dt.Rows;
            StringBuilder configString = new StringBuilder();

            for (int i = 0; i < drc.Count; i++)
            {
                string strKey = drc[i][0].ToString().Replace(" ", "");
                string strValue = drc[i][1].ToString().Replace(" ", "");
                configString.Append(strKey + "=" + strValue + "\r\n");
            }
            return configString.ToString();
        }
    }
}