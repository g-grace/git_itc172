AddShowService/App_Code/INewShowService.cs

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

    [ServiceContract]
    public interface INewShowService
{
    [OperationContract]
    List<Show> GetShows();

    [OperationContract]
    List<Artist> GetArtists();

    [OperationContract]
    bool addShow(Show s, ShowDetail sd);

    [OperationContract]
    bool addArtist(Artist a);

}



AddShowService/App_Code/Model.Context.cs

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
public virtual DbSet<Show> Shows { get; set; }
public virtual DbSet<ShowDetail> ShowDetails { get; set; }
public virtual DbSet<Venue> Venues { get; set; }
}


AddShowService/App_Code/Model.cs

using System;
using System.Collections.Generic;

public partial class Artist
{
   public Artist()
   {
      this.ShowDetails = new HashSet<ShowDetail>();
   }
   public int ArtistKey { get; set; }
   public string ArtistName { get; set; }
   public string ArtistEmail { get; set; }
   public string ArtistWebPage { get; set; }
   public Nullable<System.DateTime> ArtistDateEntered { get; set; }
   public virtual ICollection<ShowDetail> ShowDetails { get; set; }
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
}


AddShowService/App_Code/NewShowService.cs

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

// NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "NewShowService" in code, svc and config file together.
public class NewShowService : INewShowService
{
   ShowTrackerEntities db = new ShowTrackerEntities();
     
    public List<Show> GetShows()
    {
    var shs = from s in db.Shows
                  orderby s.ShowName
                 select s;

       List<Show> shows = new List<Show>();
       foreach (Show s in shs)
       {

           Show sh = new Show();
           sh.ShowName = s.ShowName;
           sh.ShowDate = s.ShowDate;
           sh.ShowTime = s.ShowTime;
shows.Add(sh);

      }

        return shows;
    }

    public List<Artist> GetArtists()
    {
       var arts = from a in db.Artists
                  orderby a.ArtistKey
                 select a;

        List<Artist> artists = new List<Artist>();
        foreach (Artist a in arts)
        {
           Artist art = new Artist();
           art.ArtistKey = a.ArtistKey;
           art.ArtistName = a.ArtistName;
          artists.Add(art);
}
        return artists;
    }

    public bool addShow(Show s, ShowDetail sd)
    {
   bool result = true;
    try
    {           ShowTrackerEntities db = new ShowTrackerEntities();

Show show = new Show();
ShowDetail details = new ShowDetail();
show.ShowName = s.ShowName;
show.ShowDate = s.ShowDate;
show.ShowTicketInfo = s.ShowTicketInfo;
show.ShowDateEntered = DateTime.Now;
show.ShowTime = s.ShowTime;
show.VenueKey = s.VenueKey;
db.Shows.Add(show);
details.ShowDetailAdditional = sd.ShowDetailAdditional;
details.ArtistKey = sd.ArtistKey;
details.ShowDetailArtistStartTime = sd.ShowDetailArtistStartTime;
details.Show = show;
db.ShowDetails.Add(details);
db.SaveChanges();
}
catch
{
result = false;
}
return result;
}
public bool addArtist(Artist a)
{
bool result = true;
try
{ 
ShowTrackerEntities db = new ShowTrackerEntities();
         Artist artist = new Artist();
         artist.ArtistName = a.ArtistName;
         artist.ArtistEmail = a.ArtistEmail;
         artist.ArtistWebPage = a.ArtistWebPage;
         artist.ArtistDateEntered = DateTime.Now;
         db.Artists.Add(artist);
        db.SaveChanges();
}
catch
{
result = false;
}
return result;
} 
} 


Assignment4/App_Code/IVenueRegistrationService.cs

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

 [ServiceContract]
public interface IVenueRegistrationService
{
	[OperationContract]
    
    //Venue and VenueLogin are the tables
	bool RegisterVenue(Venue v, VenueLogin vl);

    [OperationContract]
    int VenueLogin(string userName, string Password);
}


Assignment4/App_Code/KeyCode.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for KeyCode
/// </summary>
public class KeyCode
{
    public int GetKeyCode()
    {
        Random r = new Random();
        int key = r.Next(1000000, 9999999);
        return key;
    }
} 


Assignment4/App_Code/LoginClass.cs
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

    //constructor takes in password and username
    public LoginClass(string username, string pass)
    {
        this.username = username;
        this.pass = pass;
        
    }

    //gets the user info from the database
    private void GetUserInfo()
    {
        //declare the ADO Entities
        ShowTrackerEntities1 stde = new ShowTrackerEntities1();
        //query the fields
        var info = from i in stde.VenueLogins
                   where i.VenueLoginUserName.Equals(username)
                   select new { i.VenueLoginRandom, i.VenueLoginHashed, i.VenueKey };


        //loop through the results and assign the
        //values to the field variables
       foreach (var u in info)
        {
            seed = u.VenueLoginRandom;
            dbhash = u.VenueLoginHashed;
            key = (int)u.VenueKey;

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

        //if the hash doesn't exist, the return will be false
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



Assignment4/App_Code/Model.Context.cs
using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;

public partial class ShowTrackerEntities1 : DbContext
{
    public ShowTrackerEntities1()
      : base("name=ShowTrackerEntities1")
   {
    }

    protected override void OnModelCreating(DbModelBuilder modelBuilder)
{
       throw new UnintentionalCodeFirstException();
   }

    public virtual DbSet<Venue> Venues { get; set; }
    public virtual DbSet<VenueLogin> VenueLogins { get; set; }
}


Assignment4/App_Code/Model.cs
using System;
using System.Collections.Generic;

public partial class Venue
{
   public Venue()
    {
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


Assignment4/App_Code/PasswordHash.cs

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



Assignment4/App_Code/VenueRegistrationService.cs

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
// NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "VenueRegistrationService" in code, svc and config file together.
public class VenueRegistrationService : IVenueRegistrationService
{
ShowTrackerEntities1 db = new ShowTrackerEntities1();
public bool RegisterVenue(Venue v, VenueLogin vl)
{
bool result = true;
try
{
//1. Instantiate PasswordHash()
//2. Instantiate Keycode()
//3. Pass the password and keycode to PasswordHash to get the hashed password
//4. instantiate a new instance of the Venue class from the data entities
//5. map the fields from Venue to RegisterVenue
//6. assign the new hash and the seed to the venue fields
//7. add this instance of review to the collection Venues
//8. save all the changes to the database

            PasswordHash ph = new PasswordHash();
            KeyCode kc = new KeyCode();
            int code = kc.GetKeyCode();
            byte[] dbhash = ph.HashIt(vl.VenueLoginPasswordPlain, code.ToString());

            Venue ven = new Venue();
            ven.VenueName = v.VenueName;
            ven.VenueAddress = v.VenueAddress;
            ven.VenueCity = v.VenueCity;
            ven.VenueState = v.VenueState;
            ven.VenueZipCode = v.VenueZipCode ;
            ven.VenuePhone = v.VenuePhone;
            ven.VenueEmail = v.VenueEmail;
            ven.VenueWebPage = v.VenueWebPage;
            ven.VenueAgeRestriction = v.VenueAgeRestriction;
            ven.VenueDateAdded = DateTime.Now;

            db.Venues.Add(ven);
            db.SaveChanges();

            
            VenueLogin login = new VenueLogin();
            login.VenueLoginUserName = vl.VenueLoginUserName;
            login.VenueLoginPasswordPlain = vl.VenueLoginPasswordPlain;
            login.VenueLoginRandom = code;
            login.VenueLoginHashed = dbhash;
            login.Venue = ven;               
            login.VenueLoginDateAdded = DateTime.Now;

            db.VenueLogins.Add(login);
            db.SaveChanges();

        }
        catch
        {
            result = false;
        }

        return result;
    }

    public int VenueLogin(string userName, string Password)
    {
        LoginClass lc = new LoginClass(userName, Password);
        return lc.ValidateLogin();
    }
}
