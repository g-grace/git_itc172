//LoginClass.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public class LoginClass
{
    private string pass;
    private string username;
    private int seed;
    private byte[] dbhash;
    private int key;
    private byte[] newHash;

    public LoginClass(string pass, string username)
    {
        this.pass = pass;
        this.username = username;
    }


    private void GetUserInfo()
    {
        ShowTrackerEntities stde = new ShowTrackerEntities();
        var info = from i in stde.FanLogins
        where i.FanLoginUserName.Equals(username)
        select new { i.FanLoginKey, i.FanLoginHashed, i.FanLoginRandom };

        foreach (var u in info)
        {
            seed = u.FanLoginRandom;
            dbhash = u.FanLoginHashed;
            key = u.FanLoginKey;
        }
    }

    private void GetNewHash()
    {
        PasswordHash h = new PasswordHash();
        newHash = h.HashIt(pass, seed.ToString());
    }


    private bool CompareHash()
    {
        bool goodLogin = false;

           if (dbhash != null)
        {
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
        if (!result)
        key = 0;
        return key;
    }
}

PasswordHash.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;

public class PasswordHash
{
    private string passwd;
    private string passkey;
    public Byte[] HashIt(string password, string passkey)
    {
        passwd = password;
        this.passkey = passkey;

        Byte[] originalBytes;
        Byte[] encodedBytes;
        
        SHA512 shaHash = SHA512.Create();
        string passToHash = passkey + passwd;
        originalBytes = ASCIIEncoding.Default.GetBytes(passToHash);
        
        //converted string and hash it
        encodedBytes = shaHash.ComputeHash(originalBytes);
        
        //hashed password
        return encodedBytes;
    }
}


//FanLoginService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
public class FanLoginService : IFanLoginService
{
    ShowTrackerEntities db = new ShowTrackerEntities();
    public Boolean registerFan(FanData f, FanLoginData fl)
    {
        try
       {
            PasswordHash hash = new PasswordHash();

            Fan fan = new Fan();
            FanLogin login = new FanLogin();
            Random rand = new Random();
            int key = rand.Next(9999999);

            fan.FanName = f.fanName;
            fan.FanEmail = f.fanEmail;
            fan.FanDateEntered = DateTime.Now;

            db.Fans.Add(fan);

            login.FanLoginUserName = fl.fanLoginUserName;
            login.FanLoginPasswordPlain = fl.fanLoginPlainPassword;
            login.FanLoginHashed = hash.HashIt(fl.fanLoginPlainPassword, key.ToString());
            login.FanLoginDateAdded = DateTime.Now;
            login.Fan = fan;
            login.FanLoginRandom = (int)key;

            db.FanLogins.Add(login);
            db.SaveChanges();
            return true;
        }
            catch (Exception ex)
        {
            return false;
        }
    }

    public int loginFan(string username, string password)
    {
        LoginClass log = new LoginClass(username, password);
        int key = log.ValidateLogin();
        return key;
    }

    public List<ShowInfo> GetShowsByVenue(string venueName)
    {
        var shws = from s in db.Shows
                   from d in s.ShowDetails
                   where s.Venue.VenueName.Equals(venueName)
                   select new
                   {
                       d.Artist.ArtistName,
                       s.ShowName,
                       s.ShowTime,
                       s.ShowDate,
                       s.ShowTicketInfo
                   };

        List<ShowInfo> shows = new List<ShowInfo>();
        foreach (var sh in shws)
        {
            ShowInfo sInfo = new ShowInfo();
            sInfo.ArtistName = sh.ArtistName;
            sInfo.ShowName = sh.ShowName;
            sInfo.ShowDate = sh.ShowDate.ToShortDateString();
            sInfo.ShowTime = sh.ShowTime.ToString();
            shows.Add(sInfo);
        }
        return shows;
    }

    public List<ArtistInfo> GetShowsByArtist(string artistName)
    {
        var artists = from a in db.Shows
                      from d in a.ShowDetails
                      where d.Artist.ArtistName.Equals(artistName)
                      select new
                      {
                          d.Artist.ArtistName,
                          a.ShowName,
                          a.ShowTime,
                          a.ShowDate,
                          a.ShowTicketInfo
                      };
       
        List<ArtistInfo> artistList = new List<ArtistInfo>();
        foreach (var a in artists)
        {
            ArtistInfo aInfo = new ArtistInfo();
            aInfo.ArtistName = a.ArtistName;
            aInfo.ShowName = a.ShowName;
            aInfo.ShowTime = a.ShowTime.ToString();
            aInfo.ShowDate = a.ShowDate.ToShortDateString();
            artistList.Add(aInfo);
        }
        return artistList;
    }
}



//IFanLoginService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

[ServiceContract]
public interface IFanLoginService
{
	[OperationContract]
    Boolean registerFan(FanData f, FanLoginData fl);

    [OperationContract]
    int loginFan(string username, string password);

    [OperationContract]
    List<ShowInfo> GetShowsByVenue(string venueName);

    [OperationContract]
    List<ArtistInfo> GetShowsByArtist(string artistName);
}


[DataContract]
public class FanData
{
    [DataMember]
    public string fanName { get; set; }

    [DataMember]
    public string fanEmail { get; set; }
}


[DataContract]
public class FanLoginData
{
    [DataMember]
    public string fanLoginUserName { get; set; }
    
    [DataMember]
    public string fanLoginPlainPassword { set; get; }
}


[DataContract]
public class ShowInfo
{
    [DataMember]
    public string ArtistName { get; set; }

    [DataMember]
    public string ShowName { get; set; }

    [DataMember]
    public string ShowDate { get; set; }

    [DataMember]
    public string ShowTime { get; set; }

    [DataMember]
    public string TicketInfo { get; set; }
}


[DataContract]
public class ArtistInfo
{
    [DataMember]
    public string ArtistName { get; set; }

    [DataMember]
    public string ShowName { get; set; }

    [DataMember]
    public string ShowDate { get; set; }

    [DataMember]
    public string ShowTime { get; set; }

    [DataMember]
    public string TicketInfo { get; set; }
}


//ShowTrackerModel.cs
using System;
using System.Collections.Generic;
public partial class Artist
{
    public Artist()
    {
        this.ShowDetails = new HashSet<ShowDetail>();
        this.Genres = new HashSet<Genre>();
        this.Fans = new HashSet<Fan>();
    }

    public int ArtistKey { get; set; }
    public string ArtistName { get; set; }
    public string ArtistEmail { get; set; }
    public string ArtistWebPage { get; set; }
    public Nullable<System.DateTime> ArtistDateEntered { get; set; }
    public virtual ICollection<ShowDetail> ShowDetails { get; set; }
    public virtual ICollection<Genre> Genres { get; set; }
    public virtual ICollection<Fan> Fans { get; set; }
}


public partial class Fan
{
    public Fan()
    {
        this.FanLogins = new HashSet<FanLogin>();
        this.Artists = new HashSet<Artist>();
        this.Genres = new HashSet<Genre>();
    }
    public int FanKey { get; set; }
    public string FanName { get; set; }
    public string FanEmail { get; set; }
    public Nullable<System.DateTime> FanDateEntered { get; set; }
    public virtual ICollection<FanLogin> FanLogins { get; set; }
    public virtual ICollection<Artist> Artists { get; set; }
    public virtual ICollection<Genre> Genres { get; set; }
}


public partial class FanLogin
{
    public int FanLoginKey { get; set; }
    public Nullable<int> FanKey { get; set; }
    public string FanLoginUserName { get; set; }
    public string FanLoginPasswordPlain { get; set; }
    public int FanLoginRandom { get; set; }
    public byte[] FanLoginHashed { get; set; }
    public Nullable<System.DateTime> FanLoginDateAdded { get; set; }
    public virtual Fan Fan { get; set; }
}


public partial class Genre
{
    public Genre()
    {
        this.Artists = new HashSet<Artist>();
        this.Fans = new HashSet<Fan>();
    }

    public int GenreKey { get; set; }
    public string GenreName { get; set; }
    public string GenreDescription { get; set; }
    public virtual ICollection<Artist> Artists { get; set; }
    public virtual ICollection<Fan> Fans { get; set; }
}


public partial class LoginHistory
{
    public int LoginHistorykey { get; set; }
    public string UserName { get; set; }
    public Nullable<System.DateTime> LoginHistoryDateTime { get; set; }
}


public partial class Show

{
    public Show()
    {
        this.ShowDetails = new HashSet<ShowDetail>();
    }

    public int ShowKey { get; set; }
    public string ShowName { get; set; }
    public Nullable<int> VenueKey { get; set; }
    public System.DateTime ShowDate { get; set; }
    public System.TimeSpan ShowTime { get; set; }
    public string ShowTicketInfo { get; set; }
    public Nullable<System.DateTime> ShowDateEntered { get; set; }
    public virtual Venue Venue { get; set; }
    public virtual ICollection<ShowDetail> ShowDetails { get; set; }
}

public partial class ShowDetail
{
    public int ShowDetailKey { get; set; }
    public Nullable<int> ShowKey { get; set; }
    public Nullable<int> ArtistKey { get; set; }
    public System.TimeSpan ShowDetailArtistStartTime { get; set; }
    public string ShowDetailAdditional { get; set; }
    public virtual Artist Artist { get; set; }
    public virtual Show Show { get; set; }
}

public partial class Venue
{
    public Venue()
    {
        this.Shows = new HashSet<Show>();
        this.VenueLogins = new HashSet<VenueLogin>();
    }

    public int VenueKey { get; set; }
    public string VenueName { get; set; }
    public string VenueAddress { get; set; }
    public string VenueCity { get; set; }
    public string VenueState { get; set; }
    public string VenueZipCode { get; set; }
    public string VenuePhone { get; set; }
    public string VenueEmail { get; set; }
    public string VenueWebPage { get; set; }
    public Nullable<int> VenueAgeRestriction { get; set; }
    public Nullable<System.DateTime> VenueDateAdded { get; set; }
    public virtual ICollection<Show> Shows { get; set; }
    public virtual ICollection<VenueLogin> VenueLogins { get; set; }
}

public partial class VenueLogin
{
    public int VenueLoginKey { get; set; }
    public Nullable<int> VenueKey { get; set; }
    public string VenueLoginUserName { get; set; }
    public string VenueLoginPasswordPlain { get; set; }
    public int VenueLoginRandom { get; set; }
    public byte[] VenueLoginHashed { get; set; }
    public Nullable<System.DateTime> VenueLoginDateAdded { get; set; }
    public virtual Venue Venue { get; set; }
}


//ShowTrackerModel.Context.cs
using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;

public partial class ShowTrackerEntities : DbContext
{
    public ShowTrackerEntities()
        : base("name=ShowTrackerEntities")
    {

    }

    protected override void OnModelCreating(DbModelBuilder modelBuilder)
    {
        throw new UnintentionalCodeFirstException();
    }
    public virtual DbSet<Artist> Artists { get; set; }
    public virtual DbSet<Fan> Fans { get; set; }
    public virtual DbSet<FanLogin> FanLogins { get; set; }
    public virtual DbSet<Genre> Genres { get; set; }
    public virtual DbSet<LoginHistory> LoginHistories { get; set; }
    public virtual DbSet<Show> Shows { get; set; }
    public virtual DbSet<ShowDetail> ShowDetails { get; set; }
    public virtual DbSet<Venue> Venues { get; set; }
    public virtual DbSet<VenueLogin> VenueLogins { get; set; }
}


//StyleSheet.css
    body, body * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    padding-top: 10px;
    background-color: lemon chiffon;
}

form {
    max-width: 800px;
    margin: 0 auto;
    background-color: aquamarine;
    padding: 10px;
    border: 2px solid sky-blue;
    border-radius: 2px;
}

select {
    margin-bottom: 10px;
}

table, th, tr, td {
    border: 2px solid skyblue;
    padding: 10px;
}

th {
    background-color: antique white;
    color: white;
}


*********Client Section*******
Default.aspx
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ServiceReference1;
public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    
    protected void btnLogin_Click(object sender, EventArgs e)
    {
        ServiceReference1.FanLoginServiceClient fan = new FanLoginServiceClient();
        int key = fan.loginFan(txtUserName.Text, txtPassword.Text);
        if (key > 0)
        {
            Session["key"] = key;
            Response.Redirect("Shows.aspx");
        }
        else
        {
            lbResult.Text = "login failed";
        }
    }
}


//Default.aspx.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ServiceReference1;
public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    
    }
    protected void btnLogin_Click(object sender, EventArgs e)
    {
        //returns a key larger than zero if the login is successful
        ServiceReference1.FanLoginServiceClient fan = new FanLoginServiceClient();
        int key = fan.loginFan(txtUserName.Text, txtPassword.Text);
        if (key > 0)
        {
            Session["key"] = key;
            Response.Redirect("Shows.aspx");
        }
        else
        {
            lbResult.Text = "login failed";
        }
    }
}


  //Register.aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
        <head runat="server">
        <title>Register a fan</title>
      <link href="StyleSheet.css" rel="stylesheet" />
    </head>
<body>
<form id="form1" runat="server">
<div>
<h1>Register a fan</h1>
    <table>
        <tr>
            <td>Fan name</td>
            <td class="auto-style1"><asp:TextBox ID="txtFanName" runat="server"></asp:TextBox></td>
        </tr>

        <tr>
            <td>Email</td>
            <td class="auto-style1"><asp:TextBox ID="txtEmail" runat="server"></asp:TextBox></td>
        </tr>

         <tr>
            <td>User Name</td>
            <td class="auto-style1"><asp:TextBox ID="txtUserName" runat="server"></asp:TextBox>
             </td>
        </tr>

         <tr>
            <td>Password</td>
            <td class="auto-style1"><asp:TextBox ID="txtPassword" runat="server"  TextMode="Password"></asp:TextBox></td>
        </tr>

         <tr>
            <td>Confirm Password</td>
            <td class="auto-style1"><asp:TextBox ID="txtPassword2" runat="server" TextMode="Password"></asp:TextBox></td>
        </tr>
        
         <tr>
            <td>
            <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" /></td>

            <td>
            <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label></td>
        </tr>
    </table><br />

        <div>
        <p> Pls. check if you would like to join our Fan Club</p>
        <asp:CheckBox ID="FanClub" runat="server" Text="Join Fan Club" AutoPostBack="true" OnCheckedChanged="FanClub_CheckedChanged" CausesValidation="false"></asp:CheckBox><br/><br/>
        <asp:Label ID="Label2" runat="server" Text=""></asp:Label></td><br /><br />
        </div>

       <asp:LinkButton ID="LinkButton1" runat="server" PostBackUrl="Default.aspx" CausesValidation="false">Login</asp:LinkButton>

         <asp:CompareValidator ID="CompareValidator1" runat="server" ErrorMessage="Passwords must match" ControlToValidate="txtPassword" ControlToCompare="txtPassword2" Operator="Equal"></asp:CompareValidator>

        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ErrorMessage="Must enter valid email" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="txtEmail"></asp:RegularExpressionValidator>

        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="User name required" ControlToValidate="txtUserName" Display="None"></asp:RequiredFieldValidator>
    </div>
        <asp:ValidationSummary ID="ValidationSummary1" runat="server" />
    </form>
</body>
</html>


//Register.aspx.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ServiceReference1;

public partial class Register : System.Web.UI.Page
{
    FanLoginServiceClient fan = new FanLoginServiceClient();
    protected void Page_Load(object sender, EventArgs e)
    {
    
    }
    protected void btnRegister_Click(object sender, EventArgs e)

    {
//instantiating a fanLoginservice reference object, and the two datacontracts for fan and login

        ServiceReference1.FanLoginServiceClient fs = new       
        ServiceReference1.FanLoginServiceClient();
        ServiceReference1.FanData fan = new ServiceReference1.FanData();
        ServiceReference1.FanLoginData login = new ServiceReference1.FanLoginData();

        fan.fanName = txtFanName.Text;
        fan.fanEmail = txtEmail.Text;

        login.fanLoginPlainPassword = txtPassword.Text;
        login.fanLoginUserName = txtUserName.Text;

//registerFan returns true if user was added to database, otherwise returns false
Boolean goodRegister = fs.registerFan(fan, login);
        if (goodRegister)
        {
            lblMessage.Text = "Registered Successfully";
        }
        else
        {
            lblMessage.Text = "Error in registration. Try again";
        }
    }
    protected void FanClub_CheckedChanged(object sender, EventArgs e)
    {
        if (FanClub.Checked)
        {
            Label2.Text = “Welcome to Fan Club Society”;
        }
        else
        {
            Label2.Text = " ";
        }
    }
}


  Shows.aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Shows.aspx.cs" Inherits="Shows" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="StyleSheet.css" rel="stylesheet" />
    <title>Search Shows</title>
</head>

<body>
    <form id="form1" runat="server">
    <div>
        <h1>Search for shows</h1><br />
        <asp:Image ID="Image2" runat="server"  ImageUrl="~/show.jpg"/><br/><br/><br/>
             
<div>
<h2>Search by artist:</h2><br/>
<asp:TextBox ID="TextBox2" runat="server"></asp:TextBox><br/>
<asp:GridView ID="GridView2" runat="server"></asp:GridView><br/>
<asp:Button ID="Button2" runat="server" Text="Get Artist" OnClick="Button2_Click" /><br/><br/><br/>
     </div>

        <div>
    <h2>Search by venue:</h2><br/>
<asp:TextBox ID="TextBox1" runat="server"></asp:TextBox><br />
<asp:GridView ID="GridView1" runat="server"></asp:GridView><br/>
<asp:Button ID="Button1" runat="server" Text="Get Venue" OnClick="Button1_Click" />
        </div>
    </div>
    </form>
</body>
</html>


Shows.aspx.cs    
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ServiceReference1;

public partial class Shows : System.Web.UI.Page
{
    FanLoginServiceClient fan = new FanLoginServiceClient();
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Button2_Click(object sender, EventArgs e)
    {
    ServiceReference1.FanLoginServiceClient sc = new 
    ServiceReference1.FanLoginServiceClient();
    ServiceReference1.ArtistInfo[] artists = sc.GetShowsByArtist(TextBox2.Text);
    GridView2.DataSource = artists;
    GridView2.DataBind();
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        ServiceReference1.FanLoginServiceClient sc = new    
        ServiceReference1.FanLoginServiceClient();
        ServiceReference1.ShowInfo[] shows = sc.GetShowsByVenue(TextBox1.Text);
        GridView1.DataSource = shows;
        GridView1.DataBind();
    }
}
StyleSheet.css  
      body, body * {
    margin: 5px;
    padding: 5px;
    box-sizing: border-box;
}
body {
    padding-top: 10px;
    background-color: ivory;
}
form {
    max-width: 800px;
    margin: 0 auto;
    background-color: white;
    border: 2px solid black;
    border-rad;
    border-radius: 2px;
    padding-left:10px;
    padding-top:10px;
    padding-bottom:10px;
}
select {
    margin-bottom: 10px;
}
table, th, tr, td {
    border-collapse: collapse;
    border: 2px solid black;
    padding: 4px;
}
th {
    background-color: blue;
    color: white;
}
h1 {
    color:green;
}
#Label2 {
    color:yellow;
}






