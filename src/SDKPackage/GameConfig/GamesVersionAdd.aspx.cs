using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Core;
using System.Diagnostics;
using System.IO;
using System.Xml;

namespace SDKPackage.GameConfig
{
    public partial class GamesVersionAdd : System.Web.UI.Page
    {
        private string gameName;
        private string gameVersion;
        private string gameVersionCode;
        private string fileName;
        private string SDKPackageDir;
        private string uploadPatch;
        private string uploadFile;
        private bool isDefaultVersion;

        private static string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SdkPackageConnString"].ToString();
        private SqlConnection con = new SqlConnection(connStr);


        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["gameName"] == null)
            {
                LogLabel.Text = "没有指定游戏";
                saveButton.Enabled = false;
            }
            else
            {
                gameName = Request.QueryString["gameName"];
            }
        }



        public static bool UnZip(string fileToUnZip, string zipedFolder, string password)
        {
            bool result = true;
            FileStream fs = null;
            ZipInputStream zipStream = null;
            ZipEntry ent = null;
            string fileName;

            if (!File.Exists(fileToUnZip))
                return false;

            if (!Directory.Exists(zipedFolder))
                Directory.CreateDirectory(zipedFolder);

            try
            {
                zipStream = new ZipInputStream(File.OpenRead(fileToUnZip));
                if (!string.IsNullOrEmpty(password)) zipStream.Password = password;
                while ((ent = zipStream.GetNextEntry()) != null)
                {
                    if (ent.Name.Contains("AndroidManifest.xml"))
                    {
                        fileName = Path.Combine(zipedFolder, ent.Name);
                        fileName = fileName.Replace('/', '\\');//change by Mr.HopeGi   

                        //if (fileName.EndsWith("\\"))
                        //{
                        Directory.CreateDirectory(zipedFolder+"Game\\");
                            //continue;
                        //}

                        fs = File.Create(fileName);
                        int size = 2048;
                        byte[] data = new byte[size];
                        while (true)
                        {
                            size = zipStream.Read(data, 0, data.Length);
                            if (size > 0)
                            {
                                fs.Write(data, 0, size);
                                fs.Flush();
                            }
                            else
                                break;
                        }
                    }
                }
            }
            catch
            {
                result = false;
            }
            finally
            {
                if (fs != null)
                {
                    fs.Close();
                    fs.Dispose();
                }
                if (zipStream != null)
                {
                    zipStream.Close();
                    zipStream.Dispose();
                }
                if (ent != null)
                {
                    ent = null;
                }
                GC.Collect();
                GC.Collect(1);
            }
            return result;
        }

        private SqlCommand PrepareCommand(string strSQL, CommandType cmdType, params SqlParameter[] values)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = Con;
            cmd.CommandText = strSQL;
            cmd.CommandType = cmdType;
            cmd.CommandTimeout = 60;
            cmd.Parameters.AddRange(values);
            return cmd;
        }


        public SqlConnection Con
        {
            get
            {
                switch (con.State)
                {
                    case ConnectionState.Broken:
                        con.Close(); //先正常关闭，释放资源
                        con.Open();
                        break;
                    case ConnectionState.Closed:
                        con.Open();
                        break;
                    case ConnectionState.Connecting:
                        break;
                    case ConnectionState.Executing:
                        break;
                    case ConnectionState.Fetching:
                        break;
                    case ConnectionState.Open:
                        break;
                    default:
                        break;
                }
                return con;
            }
            set { con = value; }
        }

        public DataSet GetDataSet(string strSQL, CommandType cmdType, params SqlParameter[] values)
        {
            SqlCommand cmd = PrepareCommand(strSQL, cmdType, values);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataSet ds = new DataSet();
            da.Fill(ds);
            return ds;
        }

        protected DataTable GetPlatformManifest(string platfromName)
        {
            DataSet ds = GetDataSet("sdk_getPlatformManifest", CommandType.StoredProcedure, new SqlParameter("@platformName", platfromName));
            return ds.Tables[0];
        }

        protected void saveButton_Click(object sender, EventArgs e)
        {

            if (GameVersionFileUpload.FileName == "")
            {
                LogLabel.Text = "请选择需要上传的游戏项目";
                GameVersionFileUpload.Focus();
            }
            else
            {
                fileName = GameVersionFileUpload.FileName;
                SDKPackageDir = System.Configuration.ConfigurationManager.AppSettings["SDKPackageDir"];
                uploadPatch = SDKPackageDir + "Game\\" + gameName + "\\tmp\\";
                uploadFile = uploadPatch + fileName;
                isDefaultVersion = true;

                //try
                //{
                    if (!System.IO.Directory.Exists(uploadPatch))
                    {
                        System.IO.Directory.CreateDirectory(uploadPatch);
                    }
                    if (System.IO.File.Exists(uploadFile))
                    {
                        File.Delete(uploadFile);
                    }
                    GameVersionFileUpload.SaveAs(uploadFile);

                    if (Directory.Exists(uploadPatch+"\\Game"))
                    {
                        Directory.Delete(uploadPatch + "\\Game", true);
                    }

                    if (UnZip(uploadFile, uploadPatch, null))
                    {
                        XmlDocument AndroidManifest = new XmlDocument();
                        String AndroidManifestFile = uploadPatch + @"Game\AndroidManifest.xml";
                       
                        AndroidManifest.Load(AndroidManifestFile);
                        XmlNode manifest = AndroidManifest.SelectSingleNode("manifest");
                        //XmlNode application = manifest.SelectSingleNode("application");
                        //XmlNode activity = application.SelectSingleNode("activity");
                        //string package = manifest.Attributes["package"].Value;
                        //manifest.Attributes["package"].Value = "@package@";
                        //if (activity.Attributes["android:launchMode"].Value == "singleTask")
                        //{
                        //    activity.Attributes["android:launchMode"].Value = "singleTop";
                        //}
                        gameVersion = manifest.Attributes["android:versionName"].Value;
                        gameVersionCode = manifest.Attributes["android:versionCode"].Value;

                                                //XmlComment manifest_add = AndroidManifest.CreateComment("application_sdk");
                        //manifest.AppendChild(manifest_add);


                        //XmlComment application_add = AndroidManifest.CreateComment("manifest_sdk");
                        //application.AppendChild(application_add);

                        //AndroidManifest.Save(AndroidManifestFile);
                        

                        string savePatch = SDKPackageDir + "Game\\" + gameName + "\\" + gameVersion + TextBoxVersionLabel.Text;
                        string saveFile = savePatch + "\\Game.zip";
                        string versionFile = savePatch + "\\version.properties";

                        if (!System.IO.Directory.Exists(savePatch))
                        {
                            System.IO.Directory.CreateDirectory(savePatch);
                        }
                        else
                        {
                            if (File.Exists(saveFile))
                            {
                                File.Delete(saveFile);
                            }
                            if (File.Exists(versionFile))
                            {
                                File.Delete(versionFile);
                            }
                        }

                        File.Move(uploadFile, saveFile);
                        
                        StreamWriter sw = new StreamWriter(versionFile, false, Encoding.UTF8);
                        sw.WriteLine("version=gameversion");
                        sw.WriteLine("version.code=" + gameVersionCode);
                        sw.WriteLine("version.name=" + gameVersion);
                        sw.Flush();
                        sw.Close();

                        string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SdkPackageConnString"].ToString();
                        SqlConnection conn = new SqlConnection(connStr);
                        SqlCommand saveVersionCmd = new SqlCommand("sdk_addGameVersion", conn);
                        saveVersionCmd.CommandType = CommandType.StoredProcedure;
                        saveVersionCmd.Parameters.Add("@GameName", SqlDbType.NVarChar, 200);
                        saveVersionCmd.Parameters.Add("@GameVersion", SqlDbType.NVarChar, 200);
                        saveVersionCmd.Parameters.Add("@isDefault", SqlDbType.Bit);

                        saveVersionCmd.Parameters["@GameName"].Value = gameName;
                        saveVersionCmd.Parameters["@GameVersion"].Value = gameVersion + TextBoxVersionLabel.Text;
                        saveVersionCmd.Parameters["@isDefault"].Value = isDefaultVersion;

                        saveVersionCmd.Connection.Open();
                        saveVersionCmd.ExecuteNonQuery();
                        saveVersionCmd.Connection.Close();
                        LogLabel.Text = "版本上传成功";
                        Response.Write("<script language='javascript'>window.location='GameVersionAddSuccess.aspx'</script>");
                    }
                //}
                //catch
                //{
                //    LogLabel.Text = "版本上传失败";
                //}
            }
        }
    }
}