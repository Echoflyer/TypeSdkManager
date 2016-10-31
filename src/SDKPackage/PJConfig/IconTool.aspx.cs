using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SDKPackage.PJConfig
{
    public partial class IconTool : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ButtonCreateIcon_Click(object sender, EventArgs e)
        {
            string saveIconPatch;
            string mastIconFile;
            string ssIconFile;
            string bodyIconFile;
            string IconName = IconNameTextBox.Text;
            string mastIconName = DropDownListMaster.SelectedValue.ToString();
            string ssIconName = DropDownListSS.SelectedValue.ToString();
            string SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKPackageDir"];
            
            string IconPatch = SDKPackageDir + "ICON\\" + IconName + "\\";
            createPatch(IconPatch);

            string mastIconPatch = SDKPackageDir + "ICON\\" + mastIconName + "\\";
            string ssIconPatch = SDKPackageDir + "ICON\\" + ssIconName + "\\";

            string[] IconType = { "drawable", "drawable-ldpi", "drawable-mdpi", "drawable-hdpi", "drawable-xhdpi", "drawable-xxhpi" };
            string bodyIcon = SDKPackageDir + "ICON\\white\\";
            try
            {
                for (int i = 0; i < IconType.Length; i++)
                {
                    saveIconPatch = IconPatch + IconType[i];
                    createPatch(saveIconPatch);
                    mastIconFile = mastIconPatch + IconType[i] + "\\app_icon.png";
                    ssIconFile = ssIconPatch + IconType[i] + "\\app_icon.png";
                    bodyIconFile = bodyIcon + "\\app_icon.png";
                    createIcon(bodyIconFile, mastIconFile, ssIconPatch, saveIconPatch);
                }
                string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SdkPackageConnString"].ToString();
                SqlConnection conn = new SqlConnection(connStr);
                SqlCommand saveIconCom = new SqlCommand("sdk_setIcon", conn);
                saveIconCom.CommandType = CommandType.StoredProcedure;
                saveIconCom.Parameters.Add("@IconName", SqlDbType.NVarChar, 200);
                saveIconCom.Parameters["@IconName"].Value = IconName;
                saveIconCom.Connection.Open();
                saveIconCom.ExecuteNonQuery();
                saveIconCom.Connection.Close();
            }catch
            {

            }
            
        }

        private void createIcon(string bodyIcon, string masterIcon, string SSIcon, string savePatch)
        {
            SDKPackage.PJConfig.IconCreate.favoriteImage[] FaImage = new SDKPackage.PJConfig.IconCreate.favoriteImage[2];
            FaImage[0].x = 0;
            FaImage[0].y = 0;
            FaImage[0].imagePath = masterIcon;

            FaImage[1].x = 0;
            FaImage[1].y = 0;
            FaImage[1].imagePath = SSIcon;

            SDKPackage.PJConfig.IconCreate.generateWinterMark(savePatch, bodyIcon, FaImage);
        }

        private void createPatch(string patch)
        {
            if (!System.IO.Directory.Exists(patch))
            {
                System.IO.Directory.CreateDirectory(patch);
            }
        }
    }
}