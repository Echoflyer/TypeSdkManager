using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Drawing;

namespace SDKPackage.PJConfig
{
    public partial class AppIcon : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ButtonAddIcon_Click(object sender, EventArgs e)
        {
            string IconName = IconNameTextBox.Text;
            string SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKPackageDir"];
            string uploadPatch = SDKPackageDir + "ICON\\" + IconName + "\\";
            try
            {
                if (!System.IO.Directory.Exists(uploadPatch))
                {
                    System.IO.Directory.CreateDirectory(uploadPatch);
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable-ldpi\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable-mdpi\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable-hdpi\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable-xhdpi\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable-xxhdpi\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "drawable-xxxhdpi\\");
                    System.IO.Directory.CreateDirectory(uploadPatch + "512\\");
                }
                FileUpload.SaveAs(uploadPatch + "drawable\\app_icon.png");
                FileUpload36.SaveAs(uploadPatch + "drawable-ldpi\\app_icon.png");
                FileUpload48.SaveAs(uploadPatch + "drawable-mdpi\\app_icon.png");
                FileUpload72.SaveAs(uploadPatch + "drawable-hdpi\\app_icon.png");
                FileUpload96.SaveAs(uploadPatch + "drawable-xhdpi\\app_icon.png");
                FileUpload144.SaveAs(uploadPatch + "drawable-xxhdpi\\app_icon.png");
                FileUpload192.SaveAs(uploadPatch + "drawable-xxxhdpi\\app_icon.png");
                FileUpload512.SaveAs(uploadPatch + "512\\app_icon.png");

                string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SdkPackageConnString"].ToString();
                SqlConnection conn = new SqlConnection(connStr);
                SqlCommand saveIconCom = new SqlCommand("sdk_setIcon", conn);
                saveIconCom.CommandType = CommandType.StoredProcedure;
                saveIconCom.Parameters.Add("@IconName", SqlDbType.NVarChar, 200);
                saveIconCom.Parameters["@IconName"].Value = IconName;
                saveIconCom.Connection.Open();
                saveIconCom.ExecuteNonQuery();
                saveIconCom.Connection.Close();
                ListView1.DataBind();

                MessageLabel.Text = "成功上传图标组";
            }
            catch (Exception ex)
            {
                MessageLabel.Text = ex.Message.ToString();
            }
            
        }

        private void createIcon(string masterIcon, string SSIcon, string savePatch)
        {
            SDKPackage.PJConfig.IconCreate.favoriteImage[] FaImage = new SDKPackage.PJConfig.IconCreate.favoriteImage[1];
            FaImage[0].x = 0;
            FaImage[0].y = 0;
            FaImage[0].imagePath = SSIcon;
            SDKPackage.PJConfig.IconCreate.generateWinterMark(savePatch, masterIcon, FaImage);
        }

        private void createPatch(string patch)
        {
            if (!System.IO.Directory.Exists(patch))
            {
                System.IO.Directory.CreateDirectory(patch);
            }
        }
        protected void ButtonComposeIcon_Click(object sender, EventArgs e)
        {
            string saveIconPatch;
            string bodyIconFile;
            string IconName = TextBox1.Text;

            string SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKPackageDir"];
            string iconPatch = SDKPackageDir + "\\ICON";

            string masterSaveFileName;
            string masterIconPatch;

            masterIconPatch = SDKPackageDir + "\\ICON\\" + DropDownList1.SelectedValue + "\\";

            string ssUploadFileMd5;
            string ssUploadFileLastName;
            string ssUploadFileName;
            string ssSavePatch;
            string ssSaveFileName;

            if (SSFileUpload.HasFile)
            {
                ssUploadFileName = SSFileUpload.FileName;
                ssUploadFileLastName = ssUploadFileName.Substring(ssUploadFileName.LastIndexOf(".") + 1, (ssUploadFileName.Length - ssUploadFileName.LastIndexOf(".") - 1));
                ssUploadFileMd5 = GetMD5HashFromFile(SSFileUpload.FileContent);
                ssSavePatch = iconPatch + "\\Upload";
                ssSaveFileName = ssSavePatch + "\\" + ssUploadFileMd5 + "." + ssUploadFileLastName;
                SSFileUpload.SaveAs(ssSaveFileName);
                if(ssUploadFileLastName == "psd")
                {
                    SDKPackage.PJConfig.ImagePsd _Psd = new SDKPackage.PJConfig.ImagePsd(ssSaveFileName);
                    _Psd.PSDImage.Save(ssSavePatch + "\\" + ssUploadFileMd5 + ".png", System.Drawing.Imaging.ImageFormat.Png);
                    ssSaveFileName = ssSavePatch + "\\" + ssUploadFileMd5 + ".png";
                }
                if(SizeDropDownList.SelectedValue!="0")
                {
                    int sizePx = int.Parse(SizeDropDownList.SelectedValue);
                    ssSaveFileName = SDKPackage.PJConfig.IconCreate.generateCreateMark(ssSaveFileName, sizePx, sizePx);
                }
            }
            else
            {
                return;
            }

            string IconPatch = SDKPackageDir + "ICON\\" + IconName + "\\";
            createPatch(IconPatch);

            string[] IconType = { "drawable", "drawable-ldpi", "drawable-mdpi", "drawable-hdpi", "drawable-xhdpi", "drawable-xxhdpi", "drawable-xxxhdpi", "512" };
            //string[] IconType = { "29", "40", "80", "58", "57", "114", "180", "120", "50", "100", "72" ,"144" ,"76" ,"152", "512" };
            string bodyIcon = SDKPackageDir + "ICON\\white\\";
            try
            {
                for (int i = 0; i < IconType.Length; i++)
                {
                    masterSaveFileName = masterIconPatch + IconType[i] + "\\app_icon.png";
                    saveIconPatch = IconPatch + IconType[i];
                    createPatch(saveIconPatch);
                    bodyIconFile = bodyIcon + IconType[i] +"\\app_icon.png";
                    createIcon(masterSaveFileName, ssSaveFileName, saveIconPatch);
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
                ListView1.DataBind();
                MessageLabel.Text = "成功合成图标组";
            }
            catch (Exception ex)
            {
                MessageLabel.Text = ex.Message.ToString();
            }

        }

        private static string GetMD5HashFromFile(Stream file)
        {
            try
            {
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(file);

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                return "error";
                //throw new Exception("error");
            }
        }
    }
}