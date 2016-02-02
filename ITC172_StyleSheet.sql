StyleSheet.css
body {
    background-color:ivory;
}
table tr th{
    text-decoration-color: aqua;
    border:solid 3px azure;
    background-color:antiquewhite;
}

table tr td{
    text-decoration-color:aqua;
    border: solid 3px black;
    background-color: ivory;
}

Default.aspx.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void btnsubmit_Click(object sender, EventArgs e)
    {
        LoginClass lc = new LoginClass(txtPassword.Text, txtName.Text);
        int result = lc.ValidateLogin();
        if (result!=0)
        {
            lblResult.Text = "Welcome";
            Session["userKey"] = result;
        }
        else
        {
            lblResult.Text = "Invalid Login";
        }
    }
    protected void TxtUserName_TextChanged(object sender, EventArgs e)
    {

    }
}

Default.aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
    <link href="StyleSheet.css" type="text/css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table>
        <tr>
            <td> Enter Name</td>
            <td>
                <asp:TextBox ID="txtName" runat="server" OnTextChanged="TxtUserName_TextChanged"></asp:TextBox>
            </td>
         </tr>
             
         <tr>
            <td> Enter Password</td>
            <td>
                 <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"></asp:TextBox>
            </td>
            </tr>

          <tr>
                <td>
                    <asp:Button ID="btnsubmit" runat="server" Text="Log in" OnClick="btnsubmit_Click" /> 
                </td>
                <td>
                    <asp:Label ID="lblResult" runat="server" Text="lblResult"></asp:Label>
                </td>
           </tr>
    </table>
        <p>
            <asp:LinkButton ID="LinkButton1" runat="server" PostBackUrl="~/Registration.aspx"> Register</asp:LinkButton></p>

    </div>
    </form>
</body>
</html>

 
Registration.aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Registration.aspx.cs" Inherits="Registration" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 128px;
        }
        .auto-style2 {
            height: 26px;
        }
        .auto-style3 {
            width: 128px;
            height: 26px;
        }
    </style>
    <link href="StyleSheet.css" type="text/css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table border="1">
        <tr>
            <td class="auto-style2">Name</td>
            <td class="auto-style3"><asp:TextBox ID="txtName" runat="server" ForeColor="#FFFFCC"></asp:TextBox></td>
        </tr>
         <tr>
            <td class="auto-style2">User Name</td>
            <td class="auto-style3"><asp:TextBox ID="txtUserName" runat="server" ForeColor="#FFFFCC"></asp:TextBox></td>
        </tr>
         <tr>
            <td>Email</td>
            <td class="auto-style1"><asp:TextBox ID="txtEmail" runat="server" ForeColor="#FFFFCC"></asp:TextBox></td>
        </tr>
         <tr>
            <td>Password</td>
            <td class="auto-style1"><asp:TextBox ID="txtPassword" runat="server"  TextMode="Password" ForeColor="#FFFFCC"></asp:TextBox></td>
        </tr>
         <tr>
            <td>Confirm Password</td>
            <td class="auto-style1"><asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" ForeColor="#FFFFCC"></asp:TextBox></td>
        </tr>
         <tr>
            <td>
                <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" ForeColor="#666699" /></td>
            <td class="auto-style1">
                <asp:Label ID="lblErrorSuccess" runat="server" Text=""></asp:Label></td>
        </tr>
       
    </table>
        <asp:LinkButton ID="LbLogin" runat="server" 
PostBackUrl="~/Default.aspx" CausesValidation="False">Log in</asp:LinkButton>
    </div>
        <p>
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtName" ErrorMessage="Name Required"></asp:RequiredFieldValidator>
        </p>
        <asp:ValidationSummary ID="ValidationSummary1" runat="server" />
    </form>
</body>
</html>

PasswordHash.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography; //this adds the hash methods


public class PasswordHash
{
    private string passwd;
    private string passkey;

    public Byte[] HashIt(string password, string passkey)
    {
        passwd = password;
        this.passkey = passkey;

        //Byte arrays to store the bytes for the password
        Byte[] originalBytes;
        Byte[] encodedBytes;
        //use a modern method to hash
        SHA512 shaHash = SHA512.Create();

        //combine the passkey and the password
        string passToHash = passkey + passwd;

        //convert the string to bytes
        originalBytes = ASCIIEncoding.Default.GetBytes(passToHash);
        //take the converted string and hash it
        encodedBytes = shaHash.ComputeHash(originalBytes);

        //return the hashed password
        return encodedBytes;

    }
}

LoginClass.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for LoginClass
/// </summary>
public class LoginClass
{
		//
		// TODO: Add constructor logic here
		//


/// 
/// This class takes in the user name and password
/// retrieves information from the database
/// and then hashes the password and key to
/// see if it matches the database hash
/// 

    //class level variables-fields
    private string pass;
    private string username;
    private int seed;
    private byte[] dbhash;
    private int key;
    private byte[] newHash;
 
    //constructor takes in password and username
    public LoginClass(string pass, string username)
 {
        this.pass = pass;
        this.username = username;
 }

    //gets the user info from the database
    private void GetUserInfo()
    {
        //declare the ADO Entities
        ShowTrackerEntities brde = new ShowTrackerEntities();
        //query the fields
        var info = from i in brde.FanLogins
                   where i.FanLoginUserName.Equals(username)
                   select new { i.FanLoginRandom, i.FanLoginHashed, i.FanKey };

        //loop through the results and assign the
        //values to the field variables
        foreach(var u in info)
        {
            seed = u.FanLoginRandom;
            dbhash = u.FanLoginHashed;
            key = (int)u.FanKey;
        }
    }

    private void GetNewHash()
    {
       //get the new hash
        PasswordHash h = new PasswordHash();
        newHash = h.HashIt(pass, seed.ToString());
    }

    private bool CompareHash()
    {
        //compare the hashes
        bool goodLogin = false;

        //if the hash doesn't exist
        //because not a valid user
        //the return will be false
        if (dbhash != null)
        {
            //if the hashes do match return true
            if (newHash.SequenceEqual(dbhash))
                goodLogin = true;
        }

        return goodLogin;

    }

    public int ValidateLogin()
    {
        //call the methods
        GetUserInfo();
        GetNewHash();
        bool result = CompareHash();

        //if the result is not true
        //set the key to 0
        if (!result)
            key = 0;
            

        return key;
    }

}


Registration.aspx.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Registration : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void btnRegister_Click(object sender, EventArgs e)
    {
        ShowTrackerEntities db = new ShowTrackerEntities();
        Fan f = new Fan();
        f.FanName = txtName.Text;
        f.FanEmail = txtEmail.Text;
        f.FanDateEntered = DateTime.Now;

        KeyCode kc = new KeyCode();
        int code = kc.GetKeyCode();
        PasswordHash ph = new PasswordHash();

        FanLogin fl = new FanLogin();
        fl.Fan = f;


      //  try //try the code for errors
      //{
            //get the hashed password
        Byte[] hashed = ph.HashIt(txtPassword.Text, code.ToString());
            //assign the values to the fields of the FanLogin Class
        fl.FanLoginHashed = hashed;
        fl.FanLoginRandom = code;
        fl.FanLoginUserName = txtUserName.Text;
        fl.FanLoginPasswordPlain = txtPassword.Text;
        fl.FanLoginDateAdded = DateTime.Now;
        db.Fans.Add(f);
        db.FanLogins.Add(fl);
        db.SaveChanges();

        lblErrorSuccess.Text = "Sucessfully Registered";
    //}
    //    catch (Exception ex)
    //{
    //    lblErrorSuccess.Text = ex.Message;
    //}
  }
}

Welcome.aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Welcome.aspx.cs" Inherits="Welcome" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
        <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
    </form>
</body>
</html>

Welcome.aspx.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Welcome : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
 {
    if(Session["userKey"]!= null)
 {
     int key = (int)Session["userKey"];
    Label1.Text = key.ToString();
 }
        else
        {
            Response.Redirect("Default.aspx");
        }

  }
}

 
 

