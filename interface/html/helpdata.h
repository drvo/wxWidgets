/////////////////////////////////////////////////////////////////////////////
// Name:        html/helpdata.h
// Purpose:     documentation for wxHtmlHelpData class
// Author:      wxWidgets team
// RCS-ID:      $Id$
// Licence:     wxWindows license
/////////////////////////////////////////////////////////////////////////////

/**
    @class wxHtmlHelpData
    @headerfile helpdata.h wx/html/helpdata.h
    
    This class is used by wxHtmlHelpController 
    and wxHtmlHelpFrame to access HTML help items.
    It is internal class and should not be used directly - except for the case 
    you're writing your own HTML help controller.
    
    @library{wxhtml}
    @category{FIXME}
*/
class wxHtmlHelpData : public wxObject
{
public:
    /**
        Constructor.
    */
    wxHtmlHelpData();

    /**
        Adds new book. @e book is URL (not filename!) of HTML help project (hhp)
        or ZIP file that contains arbitrary number of .hhp projects (this zip
        file can have either .zip or .htb extension, htb stands for "html book").
        Returns success.
    */
    bool AddBook(const wxString& book_url);

    /**
        Returns page's URL based on integer ID stored in project.
    */
    wxString FindPageById(int id);

    /**
        Returns page's URL based on its (file)name.
    */
    wxString FindPageByName(const wxString& page);

    /**
        Returns array with help books info.
    */
    const wxHtmlBookRecArray GetBookRecArray();

    /**
        Returns reference to array with contents entries.
    */
    const wxHtmlHelpDataItems GetContentsArray();

    /**
        Returns reference to array with index entries.
    */
    const wxHtmlHelpDataItems GetIndexArray();

    /**
        Sets temporary directory where binary cached versions of MS HTML Workshop
        files will be stored. (This is turned off by default and you can enable
        this feature by setting non-empty temp dir.)
    */
    void SetTempDir(const wxString& path);
};
