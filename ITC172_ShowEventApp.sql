Default (Webform)

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title></title>
<link href="StyleSheet.css" type="text/css" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">
<div>
<asp:DropDownList ID="DropDownList1" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged"></asp:DropDownList>
<asp:GridView ID="GridView1" runat="server"></asp:GridView>
</div>
</form>
</body>
</html>


Default (Database ADO)
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
public partial class _Default : System.Web.UI.Page
{
ShowTrackerEntities5 db = new ShowTrackerEntities5();
protected void Page_Load(object sender, EventArgs e)
{
var Art = from a in db.Artists
orderby a.ArtistName
select new
{a.ArtistName, a.ArtistKey};
DropDownList1.DataSource = Art.ToList();
DropDownList1.DataTextField = "ArtistName";
DropDownList1.DataValueField = "ArtistKey";
DropDownList1.DataBind();
}
protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
{
int Key = int.Parse(DropDownList1.SelectedValue.ToString());
var chars = from sd in db.ShowDetails
where sd.ArtistKey == Key
select new
{sd.Show.ShowName, sd.Show.ShowDate, sd.Artist.ArtistName};
GridView1.DataSource = chars.ToList();
GridView1.DataBind();
}
}


StyleSheet
body {
}
table tr th{
background-color:yellow;
border: solid 3px black;
padding-left: 4px;
padding-right: 4px;
}
table tr td{
border: solid 3px black;
padding-left: 4px;
padding-right: 4px;
}

 


 
