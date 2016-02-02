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
        BookReviewDbEntities db = new BookReviewDbEntities();
        Reviewer r = new Reviewer();
        r.ReviewerFirstName = txtFirstName.Text;
        r.ReviewerLastName = txtLastName.Text;
        r.ReviewerEmail = txtEmail.Text;
        r.ReviewerUserName = txtUserName.Text;
        r.ReviewPlainPassword = txtPassword.Text;

        KeyCode kc = new KeyCode();
        int code = kc.GetKeyCode();
        r.ReviewerKeyCode = code;
        PasswordHash ph = new PasswordHash();
        try //try the code for errors
        {
            //get the hashed password
        Byte[] hashed = ph.HashIt(txtPassword.Text, code.ToString());
            //assign the values to the fields of the Reviewer Class
        r.ReviewerHashedPass = hashed;
        r.ReviewerDateEntered = DateTime.Now;
        CheckinLog Log = new CheckinLog();
        Log.CheckinDateTime = DateTime.Now;
        Log.Reviewer = r;
        db.CheckinLogs.Add(Log);
        db.Reviewers.Add(r);

        lblErrorSuccess.Text = "Sucessfully Registered";
    }
        catch (Exception ex)
    {
        lblErrorSuccess.Text = ex.Message;
    }
  }
}

Welcome.aspx


Welcome.aspx.cs
sing System;
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

KeyCode.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for KeyCode
/// </summary>
public class KeyCode
{
	public KeyCode()
	{
		//
		// TODO: Add constructor logic here
		//
	}

    public int GetKeyCode()
    {
        Random rand = new Random();
        int key = rand.Next(100000, 9999999);
        return key;
    }
}

Default.aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table>
        <tr>
            <td> Enter UserName</td>
            <td>
                <asp:TextBox ID="txtUserName" runat="server" OnTextChanged="TxtUserName_TextChanged"></asp:TextBox>
            </td>
         </tr>
         <tr>
            <td> Enter Password</td>
            <td>
                 <asp:TextBox ID="txtPassword" runat="server"></asp:TextBox>
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
        LoginClass lc = new LoginClass(txtPassword.Text, txtUserName.Text);
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
        BookReviewDbEntities brde = new BookReviewDbEntities();
        //query the fields
        var info = from i in brde.Reviewers
                   where i.ReviewerUserName.Equals(username)
                   select new { i.ReviewerKey, i.ReviewerHashedPass, i.ReviewerKeyCode };

        //loop through the results and assign the
        //values to the field variables
        foreach(var u in info)
        {
            seed = u.ReviewerKeyCode;
            dbhash = u.ReviewerHashedPass;
            key = u.ReviewerKey;
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

Review Model.edmx [DIAMGRAM]



