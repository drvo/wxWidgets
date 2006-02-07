/////////////////////////////////////////////////////////////////////////////
// Name:        html.i
// Purpose:     SWIG definitions of html classes
//
// Author:      Robin Dunn
//
// Created:     25-Nov-1998
// RCS-ID:      $Id$
// Copyright:   (c) 2003 by Total Control Software
// Licence:     wxWindows license
/////////////////////////////////////////////////////////////////////////////

%define DOCSTRING
"Classes for a simple HTML rendering window, HTML Help Window, etc."
%enddef

%module(package="wx", docstring=DOCSTRING) html

%{
#include "wx/wxPython/wxPython.h"
#include "wx/wxPython/pyclasses.h"
#include "wx/wxPython/pyistream.h"
#include "wx/wxPython/printfw.h"

#include <wx/html/htmlwin.h>
#include <wx/html/htmprint.h>
#include <wx/html/helpctrl.h>
#include <wx/html/helpwnd.h>
#include <wx/html/helpfrm.h>
#include <wx/html/helpdlg.h>

%}


//---------------------------------------------------------------------------

%import windows.i
%pythoncode { wx = _core }
%pythoncode { __docfilter__ = wx.__DocFilter(globals()) }

%include _html_rename.i


MAKE_CONST_WXSTRING_NOSWIG(EmptyString);
MAKE_CONST_WXSTRING2(HtmlWindowNameStr,    wxT("htmlWindow"))
MAKE_CONST_WXSTRING2(HtmlPrintoutTitleStr, wxT("Printout"))
MAKE_CONST_WXSTRING2(HtmlPrintingTitleStr, wxT("Printing"))


// TODO: Split this file into multiple %included files that coresponds to the
// wx/html include files (more or less.)

//---------------------------------------------------------------------------
%newgroup


enum {
    wxHTML_ALIGN_LEFT,
    wxHTML_ALIGN_CENTER,
    wxHTML_ALIGN_RIGHT,
    wxHTML_ALIGN_BOTTOM,
    wxHTML_ALIGN_TOP,

    wxHTML_CLR_FOREGROUND,
    wxHTML_CLR_BACKGROUND,

    wxHTML_UNITS_PIXELS,
    wxHTML_UNITS_PERCENT,

    wxHTML_INDENT_LEFT,
    wxHTML_INDENT_RIGHT,
    wxHTML_INDENT_TOP,
    wxHTML_INDENT_BOTTOM,

    wxHTML_INDENT_HORIZONTAL,
    wxHTML_INDENT_VERTICAL,
    wxHTML_INDENT_ALL,

    wxHTML_COND_ISANCHOR,
    wxHTML_COND_ISIMAGEMAP,
    wxHTML_COND_USER,


    wxHTML_FONT_SIZE_1,
    wxHTML_FONT_SIZE_2,
    wxHTML_FONT_SIZE_3,
    wxHTML_FONT_SIZE_4,
    wxHTML_FONT_SIZE_5,
    wxHTML_FONT_SIZE_6,
    wxHTML_FONT_SIZE_7,
};


enum {
    wxHW_SCROLLBAR_NEVER,
    wxHW_SCROLLBAR_AUTO,
    wxHW_NO_SELECTION,
    wxHW_DEFAULT_STYLE,
};


// enums for wxHtmlWindow::OnOpeningURL
enum wxHtmlOpeningStatus
{
    wxHTML_OPEN,
    wxHTML_BLOCK,
    wxHTML_REDIRECT
};

enum wxHtmlURLType
{
    wxHTML_URL_PAGE,
    wxHTML_URL_IMAGE,
    wxHTML_URL_OTHER
};



//---------------------------------------------------------------------------

class wxHtmlLinkInfo : public wxObject {
public:
    wxHtmlLinkInfo(const wxString& href, const wxString& target = wxPyEmptyString);
    wxString GetHref();
    wxString GetTarget();
    wxMouseEvent* GetEvent();
    wxHtmlCell* GetHtmlCell();

    void SetEvent(const wxMouseEvent *e);
    void SetHtmlCell(const wxHtmlCell * e);
};

//---------------------------------------------------------------------------

class wxHtmlTag : public wxObject {
public:
    // Never need to create a new tag from Python...
    //wxHtmlTag(const wxString& source, int pos, int end_pos, wxHtmlTagsCache* cache);

    wxString GetName();
    bool HasParam(const wxString& par);
    wxString GetParam(const wxString& par, int with_commas = false);

    // Can't do this one as-is, but GetParam should be enough...
    //int ScanParam(const wxString& par, const char *format, void* param);

    wxString GetAllParams();
    bool HasEnding();
    int GetBeginPos();
    int GetEndPos1();
    int GetEndPos2();
};

//---------------------------------------------------------------------------

class wxHtmlParser : public wxObject {
public:
    // wxHtmlParser();  This is an abstract base class...

    void SetFS(wxFileSystem *fs);
    wxFileSystem* GetFS();
    wxObject* Parse(const wxString& source);
    void InitParser(const wxString& source);
    void DoneParser();
    void DoParsing(int begin_pos, int end_pos);
    void StopParsing();
    // wxObject* GetProduct();

    void AddTagHandler(wxHtmlTagHandler *handler);
    wxString* GetSource();
    void PushTagHandler(wxHtmlTagHandler* handler, wxString tags);
    void PopTagHandler();

    // virtual wxFSFile *OpenURL(wxHtmlURLType type, const wxString& url) const;

    // void AddText(const char* txt) = 0;
    // void AddTag(const wxHtmlTag& tag);
};


//---------------------------------------------------------------------------

class wxHtmlWinParser : public wxHtmlParser {
public:
    wxHtmlWinParser(wxPyHtmlWindow *wnd = NULL);

    void SetDC(wxDC *dc);
    wxDC* GetDC();
    int GetCharHeight();
    int GetCharWidth();
    wxPyHtmlWindow* GetWindow();

    // Sets fonts to be used when displaying HTML page. (if size null then default sizes used).
    %extend {
        void SetFonts(wxString normal_face, wxString fixed_face, PyObject* sizes=NULL) {
            int* temp = NULL;
            if (sizes) temp = int_LIST_helper(sizes);
            self->SetFonts(normal_face, fixed_face, temp);
            if (temp)
                delete [] temp;
        }
    }

    // Sets font sizes to be relative to the given size or the system
    // default size; use either specified or default font
    void SetStandardFonts(int size = -1,
                          const wxString& normal_face = wxPyEmptyString,
                          const wxString& fixed_face = wxPyEmptyString);


    wxHtmlContainerCell* GetContainer();
    wxHtmlContainerCell* OpenContainer();
    wxHtmlContainerCell *SetContainer(wxHtmlContainerCell *c);
    wxHtmlContainerCell* CloseContainer();

    int GetFontSize();
    void SetFontSize(int s);
    int GetFontBold();
    void SetFontBold(int x);
    int GetFontItalic();
    void SetFontItalic(int x);
    int GetFontUnderlined();
    void SetFontUnderlined(int x);
    int GetFontFixed();
    void SetFontFixed(int x);
    int GetAlign();
    void SetAlign(int a);
    wxColour GetLinkColor();
    void SetLinkColor(const wxColour& clr);
    wxColour GetActualColor();
    void SetActualColor(const wxColour& clr);
    %pythoncode {
        GetActualColour = GetActualColor
        SetActualColour = SetActualColor
    }
    void SetLink(const wxString& link);
    wxFont* CreateCurrentFont();
    wxHtmlLinkInfo GetLink();

};


//---------------------------------------------------------------------------

%{
class wxPyHtmlTagHandler : public wxHtmlTagHandler {
    DECLARE_DYNAMIC_CLASS(wxPyHtmlTagHandler)
public:
    wxPyHtmlTagHandler() : wxHtmlTagHandler() {};

    wxHtmlParser* GetParser() { return m_Parser; }
    void ParseInner(const wxHtmlTag& tag) { wxHtmlTagHandler::ParseInner(tag); }

    DEC_PYCALLBACK_STRING__pure(GetSupportedTags);
    DEC_PYCALLBACK_BOOL_TAG_pure(HandleTag);

    PYPRIVATE;
};

IMPLEMENT_DYNAMIC_CLASS(wxPyHtmlTagHandler, wxHtmlTagHandler);

IMP_PYCALLBACK_STRING__pure(wxPyHtmlTagHandler, wxHtmlTagHandler, GetSupportedTags);
IMP_PYCALLBACK_BOOL_TAG_pure(wxPyHtmlTagHandler, wxHtmlTagHandler, HandleTag);
%}


%rename(HtmlTagHandler) wxPyHtmlTagHandler;
class wxPyHtmlTagHandler : public wxObject {
public:
    %pythonAppend wxPyHtmlTagHandler   "self._setCallbackInfo(self, HtmlTagHandler)"
    wxPyHtmlTagHandler();

    void _setCallbackInfo(PyObject* self, PyObject* _class);

    void SetParser(wxHtmlParser *parser);
    wxHtmlParser* GetParser();
    void ParseInner(const wxHtmlTag& tag);
};


//---------------------------------------------------------------------------

%{
class wxPyHtmlWinTagHandler : public wxHtmlWinTagHandler {
    DECLARE_DYNAMIC_CLASS(wxPyHtmlWinTagHandler)
public:
    wxPyHtmlWinTagHandler() : wxHtmlWinTagHandler() {};

    wxHtmlWinParser* GetParser() { return m_WParser; }
    void ParseInner(const wxHtmlTag& tag)
        { wxHtmlWinTagHandler::ParseInner(tag); }

    DEC_PYCALLBACK_STRING__pure(GetSupportedTags);
    DEC_PYCALLBACK_BOOL_TAG_pure(HandleTag);

    PYPRIVATE;
};

IMPLEMENT_DYNAMIC_CLASS( wxPyHtmlWinTagHandler, wxHtmlWinTagHandler);

IMP_PYCALLBACK_STRING__pure(wxPyHtmlWinTagHandler, wxHtmlWinTagHandler, GetSupportedTags);
IMP_PYCALLBACK_BOOL_TAG_pure(wxPyHtmlWinTagHandler, wxHtmlWinTagHandler, HandleTag);
%}


%rename(HtmlWinTagHandler) wxPyHtmlWinTagHandler;
class wxPyHtmlWinTagHandler : public wxPyHtmlTagHandler {
public:
    %pythonAppend wxPyHtmlWinTagHandler    "self._setCallbackInfo(self, HtmlWinTagHandler)"
    wxPyHtmlWinTagHandler();

    void _setCallbackInfo(PyObject* self, PyObject* _class);

    void SetParser(wxHtmlParser *parser);
    wxHtmlWinParser* GetParser();
    void ParseInner(const wxHtmlTag& tag);
};


//---------------------------------------------------------------------------

%{

class wxPyHtmlTagsModule : public wxHtmlTagsModule {
public:
    wxPyHtmlTagsModule(PyObject* thc) : wxHtmlTagsModule() {
        m_tagHandlerClass = thc;
        Py_INCREF(m_tagHandlerClass);
        RegisterModule(this);
        wxHtmlWinParser::AddModule(this);
    }

    void OnExit() {
        wxPyBlock_t blocked = wxPyBeginBlockThreads();
        Py_DECREF(m_tagHandlerClass);
        m_tagHandlerClass = NULL;
        for (size_t x=0; x < m_objArray.GetCount(); x++) {
            PyObject* obj = (PyObject*)m_objArray.Item(x);
            Py_DECREF(obj);
        }
        wxPyEndBlockThreads(blocked);
    };

    void FillHandlersTable(wxHtmlWinParser *parser) {
        // Wave our magic wand...  (if it works it's a miracle!  ;-)

        // First, make a new instance of the tag handler
        wxPyBlock_t blocked = wxPyBeginBlockThreads();
        PyObject* arg = PyTuple_New(0);
        PyObject* obj = PyObject_CallObject(m_tagHandlerClass, arg);
        Py_DECREF(arg);

        // now figure out where it's C++ object is...
        wxPyHtmlWinTagHandler* thPtr;
        if (! wxPyConvertSwigPtr(obj, (void **)&thPtr, wxT("wxPyHtmlWinTagHandler"))) {
            wxPyEndBlockThreads(blocked);
            return;
        }
        wxPyEndBlockThreads(blocked);

        // add it,
        parser->AddTagHandler(thPtr);

        // and track it.
        m_objArray.Add(obj);
    }

private:
    PyObject*           m_tagHandlerClass;
    wxArrayPtrVoid      m_objArray;

};
%}



%inline %{
    void wxHtmlWinParser_AddTagHandler(PyObject* tagHandlerClass) {
        // Dynamically create a new wxModule.  Refcounts tagHandlerClass
        // and adds itself to the wxModules list and to the wxHtmlWinParser.
        new wxPyHtmlTagsModule(tagHandlerClass);
    }
%}


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
%newgroup


// wxHtmlSelection is data holder with information about text selection.
// Selection is defined by two positions (beginning and end of the selection)
// and two leaf(!) cells at these positions.
class wxHtmlSelection
{
public:
    wxHtmlSelection();
    ~wxHtmlSelection();

    void Set(const wxPoint& fromPos, const wxHtmlCell *fromCell,
             const wxPoint& toPos, const wxHtmlCell *toCell);
    %Rename(SetCells, void, Set(const wxHtmlCell *fromCell, const wxHtmlCell *toCell));

    const wxHtmlCell *GetFromCell() const;
    const wxHtmlCell *GetToCell() const;

    // these values are in absolute coordinates:
    const wxPoint& GetFromPos() const;
    const wxPoint& GetToPos() const;

    // these are From/ToCell's private data
    const wxPoint& GetFromPrivPos() const;
    const wxPoint& GetToPrivPos() const;
    void SetFromPrivPos(const wxPoint& pos);
    void SetToPrivPos(const wxPoint& pos);
    void ClearPrivPos();

    const bool IsEmpty() const;

};


enum wxHtmlSelectionState
{
    wxHTML_SEL_OUT,     // currently rendered cell is outside the selection
    wxHTML_SEL_IN,      // ... is inside selection
    wxHTML_SEL_CHANGING // ... is the cell on which selection state changes
};



// Selection state is passed to wxHtmlCell::Draw so that it can render itself
// differently e.g. when inside text selection or outside it.
class wxHtmlRenderingState
{
public:
    wxHtmlRenderingState();
    ~wxHtmlRenderingState();

    void SetSelectionState(wxHtmlSelectionState s);
    wxHtmlSelectionState GetSelectionState() const;

    void SetFgColour(const wxColour& c);
    const wxColour& GetFgColour() const;
    void SetBgColour(const wxColour& c);
    const wxColour& GetBgColour() const;
};



// HTML rendering customization. This class is used when rendering wxHtmlCells
// as a callback:
class wxHtmlRenderingStyle
{
public:
    virtual wxColour GetSelectedTextColour(const wxColour& clr) = 0;
    virtual wxColour GetSelectedTextBgColour(const wxColour& clr) = 0;
};

// Standard style:
class wxDefaultHtmlRenderingStyle : public wxHtmlRenderingStyle
{
public:
    virtual wxColour GetSelectedTextColour(const wxColour& clr);
    virtual wxColour GetSelectedTextBgColour(const wxColour& clr);
};



// Information given to cells when drawing them. Contains rendering state,
// selection information and rendering style object that can be used to
// customize the output.
class wxHtmlRenderingInfo
{
public:
    wxHtmlRenderingInfo();
    ~wxHtmlRenderingInfo();

    void SetSelection(wxHtmlSelection *s);
    wxHtmlSelection *GetSelection() const;

    void SetStyle(wxHtmlRenderingStyle *style);
    wxHtmlRenderingStyle& GetStyle();

    wxHtmlRenderingState& GetState();
};

//---------------------------------------------------------------------------
%newgroup


enum
{
    wxHTML_FIND_EXACT             = 1,
    wxHTML_FIND_NEAREST_BEFORE    = 2,
    wxHTML_FIND_NEAREST_AFTER     = 4
};


class wxHtmlCell : public wxObject {
public:
    wxHtmlCell();

    int GetPosX();
    int GetPosY();
    int GetWidth();
    int GetHeight();
    int GetDescent();

    // Returns the maximum possible length of the cell.
    // Call Layout at least once before using GetMaxTotalWidth()
    int GetMaxTotalWidth() const;

    const wxString& GetId() const;
    void SetId(const wxString& id);
    wxHtmlLinkInfo* GetLink(int x = 0, int y = 0);
    wxHtmlCell* GetNext();
    wxHtmlContainerCell* GetParent();
    wxHtmlCell* GetFirstChild() const;

    // Returns cursor to be used when mouse is over the cell:
    wxCursor GetCursor() const;

    // Formatting cells are not visible on the screen, they only alter
    // renderer's state.
    bool IsFormattingCell() const;


    void SetLink(const wxHtmlLinkInfo& link);
    void SetNext(wxHtmlCell *cell);
    void SetParent(wxHtmlContainerCell *p);
    void SetPos(int x, int y);
    void Layout(int w);
    void Draw(wxDC& dc, int x, int y, int view_y1, int view_y2,
              wxHtmlRenderingInfo& info);
    void DrawInvisible(wxDC& dc, int x, int y,
              wxHtmlRenderingInfo& info);
    const wxHtmlCell* Find(int condition, const void* param);

    bool AdjustPagebreak(int* INOUT);
    void SetCanLiveOnPagebreak(bool can);

    // Can the line be broken before this cell?
    bool IsLinebreakAllowed() const;

    // Returns True for simple == terminal cells, i.e. not composite ones.
    // This if for internal usage only and may disappear in future versions!
    bool IsTerminalCell() const;

    // Find a cell inside this cell positioned at the given coordinates
    // (relative to this's positions). Returns NULL if no such cell exists.
    // The flag can be used to specify whether to look for terminal or
    // nonterminal cells or both. In either case, returned cell is deepest
    // cell in cells tree that contains [x,y].
    wxHtmlCell *FindCellByPos(wxCoord x, wxCoord y,
                                  unsigned flags = wxHTML_FIND_EXACT) const;

    // Returns absolute position of the cell on HTML canvas
    wxPoint GetAbsPos() const;

    // Returns first (last) terminal cell inside this cell. It may return NULL,
    // but it is rare -- only if there are no terminals in the tree.
    wxHtmlCell *GetFirstTerminal() const ;
    wxHtmlCell *GetLastTerminal() const ;

    // Returns cell's depth, i.e. how far under the root cell it is
    // (if it is the root, depth is 0)
    unsigned GetDepth() const;

    // Returns True if the cell appears before 'cell' in natural order of
    // cells (= as they are read). If cell A is (grand)parent of cell B,
    // then both A.IsBefore(B) and B.IsBefore(A) always return True.
    bool IsBefore(wxHtmlCell *cell) const;

    // Converts the cell into text representation. If sel != NULL then
    // only part of the cell inside the selection is converted.
    wxString ConvertToText(wxHtmlSelection *sel) const;
};


class  wxHtmlWordCell : public wxHtmlCell
{
public:
    wxHtmlWordCell(const wxString& word, wxDC& dc);
};


class wxHtmlContainerCell : public wxHtmlCell {
public:
    wxHtmlContainerCell(wxHtmlContainerCell *parent);

    void InsertCell(wxHtmlCell *cell);
    void SetAlignHor(int al);
    int GetAlignHor();
    void SetAlignVer(int al);
    int GetAlignVer();
    void SetIndent(int i, int what, int units = wxHTML_UNITS_PIXELS);
    int GetIndent(int ind);
    int GetIndentUnits(int ind);
    void SetAlign(const wxHtmlTag& tag);
    void SetWidthFloat(int w, int units);
    %Rename(SetWidthFloatFromTag, void,  SetWidthFloat(const wxHtmlTag& tag));
    void SetMinHeight(int h, int align = wxHTML_ALIGN_TOP);
    void SetBackgroundColour(const wxColour& clr);
    wxColour GetBackgroundColour();
    void SetBorder(const wxColour& clr1, const wxColour& clr2);
    wxHtmlCell* GetFirstChild();
    %pragma(python) addtoclass = "GetFirstCell = GetFirstChild"
};



class wxHtmlColourCell : public wxHtmlCell {
public:
    wxHtmlColourCell(const wxColour& clr, int flags = wxHTML_CLR_FOREGROUND);

};


class  wxHtmlFontCell : public wxHtmlCell
{
public:
    wxHtmlFontCell(wxFont *font);
};


class wxHtmlWidgetCell : public wxHtmlCell {
public:
    wxHtmlWidgetCell(wxWindow* wnd, int w = 0);

};




//---------------------------------------------------------------------------
// wxHtmlFilter
//---------------------------------------------------------------------------
%newgroup


%{ // here's the C++ version
class wxPyHtmlFilter : public wxHtmlFilter {
    DECLARE_ABSTRACT_CLASS(wxPyHtmlFilter)
public:
    wxPyHtmlFilter() : wxHtmlFilter() {}

    // returns True if this filter is able to open&read given file
    virtual bool CanRead(const wxFSFile& file) const {
        bool rval = false;
        bool found;
        wxPyBlock_t blocked = wxPyBeginBlockThreads();
        if ((found = wxPyCBH_findCallback(m_myInst, "CanRead"))) {
            PyObject* obj = wxPyMake_wxObject((wxFSFile*)&file,false);  // cast away const
            rval = wxPyCBH_callCallback(m_myInst, Py_BuildValue("(O)", obj));
            Py_DECREF(obj);
        }
        wxPyEndBlockThreads(blocked);
        return rval;
    }


    // Reads given file and returns HTML document.
    // Returns empty string if opening failed
    virtual wxString ReadFile(const wxFSFile& file) const {
        wxString rval;
        bool found;
        wxPyBlock_t blocked = wxPyBeginBlockThreads();
        if ((found = wxPyCBH_findCallback(m_myInst, "ReadFile"))) {
            PyObject* obj = wxPyMake_wxObject((wxFSFile*)&file,false);  // cast away const
            PyObject* ro;
            ro = wxPyCBH_callCallbackObj(m_myInst, Py_BuildValue("(O)", obj));
            Py_DECREF(obj);
            if (ro) {
                rval = Py2wxString(ro);
                Py_DECREF(ro);
            }
        }
        wxPyEndBlockThreads(blocked);
        return rval;
    }

    PYPRIVATE;
};

IMPLEMENT_ABSTRACT_CLASS(wxPyHtmlFilter, wxHtmlFilter);
%}


// And now the version seen by SWIG

%rename(HtmlFilter) wxPyHtmlFilter;
class wxPyHtmlFilter : public wxObject {
public:
    %pythonAppend wxPyHtmlFilter   "self._setCallbackInfo(self, HtmlFilter)"
    wxPyHtmlFilter();

    void _setCallbackInfo(PyObject* self, PyObject* _class);
};


// TODO: wxHtmlFilterHTML


//---------------------------------------------------------------------------
// wxHtmlWindow
//---------------------------------------------------------------------------
%newgroup

%{
class wxPyHtmlWindow : public wxHtmlWindow {
    DECLARE_ABSTRACT_CLASS(wxPyHtmlWindow)
public:
    wxPyHtmlWindow(wxWindow *parent, wxWindowID id = -1,
                   const wxPoint& pos = wxDefaultPosition,
                   const wxSize& size = wxDefaultSize,
                   long style = wxHW_DEFAULT_STYLE,
                   const wxString& name = wxPyHtmlWindowNameStr)
        : wxHtmlWindow(parent, id, pos, size, style, name)  {};
    wxPyHtmlWindow() : wxHtmlWindow() {};

    bool ScrollToAnchor(const wxString& anchor) {
        return wxHtmlWindow::ScrollToAnchor(anchor);
    }

    bool HasAnchor(const wxString& anchor) {
        const wxHtmlCell *c = m_Cell->Find(wxHTML_COND_ISANCHOR, &anchor);
        return c!=NULL;
    }

    void OnLinkClicked(const wxHtmlLinkInfo& link);

    wxHtmlOpeningStatus OnOpeningURL(wxHtmlURLType type,
                                      const wxString& url,
                                      wxString *redirect) const;

    DEC_PYCALLBACK__STRING(OnSetTitle);
    DEC_PYCALLBACK__CELLINTINT(OnCellMouseHover);
    DEC_PYCALLBACK__CELLINTINTME(OnCellClicked);
    PYPRIVATE;
};

IMPLEMENT_ABSTRACT_CLASS( wxPyHtmlWindow, wxHtmlWindow );
IMP_PYCALLBACK__STRING(wxPyHtmlWindow, wxHtmlWindow, OnSetTitle);
IMP_PYCALLBACK__CELLINTINT(wxPyHtmlWindow, wxHtmlWindow, OnCellMouseHover);
IMP_PYCALLBACK__CELLINTINTME(wxPyHtmlWindow, wxHtmlWindow, OnCellClicked);


void wxPyHtmlWindow::OnLinkClicked(const wxHtmlLinkInfo& link) {
    bool found;
    wxPyBlock_t blocked = wxPyBeginBlockThreads();
    if ((found = wxPyCBH_findCallback(m_myInst, "OnLinkClicked"))) {
        PyObject* obj = wxPyConstructObject((void*)&link, wxT("wxHtmlLinkInfo"), 0);
        wxPyCBH_callCallback(m_myInst, Py_BuildValue("(O)", obj));
        Py_DECREF(obj);
    }
    wxPyEndBlockThreads(blocked);
    if (! found)
        wxHtmlWindow::OnLinkClicked(link);
}


wxHtmlOpeningStatus wxPyHtmlWindow::OnOpeningURL(wxHtmlURLType type,
                                                 const wxString& url,
                                                 wxString *redirect) const {
    bool found;
    wxHtmlOpeningStatus rval;
    wxPyBlock_t blocked = wxPyBeginBlockThreads();
    if ((found = wxPyCBH_findCallback(m_myInst, "OnOpeningURL"))) {
        PyObject* ro;
        PyObject* s = wx2PyString(url);
        ro = wxPyCBH_callCallbackObj(m_myInst, Py_BuildValue("(iO)", type, s));
        Py_DECREF(s);
        if (PyString_Check(ro)
#if PYTHON_API_VERSION >= 1009
            || PyUnicode_Check(ro)
#endif
            ) {
            *redirect = Py2wxString(ro);
            rval = wxHTML_REDIRECT;
        }
        else {
            PyObject* num = PyNumber_Int(ro);
            rval = (wxHtmlOpeningStatus)PyInt_AsLong(num);
            Py_DECREF(num);
        }
        Py_DECREF(ro);
    }
    wxPyEndBlockThreads(blocked);
    if (! found)
        rval = wxHtmlWindow::OnOpeningURL(type, url, redirect);
    return rval;
}


%}



MustHaveApp(wxPyHtmlWindow);

%rename(HtmlWindow) wxPyHtmlWindow;
class wxPyHtmlWindow : public wxScrolledWindow {
public:
    %pythonAppend wxPyHtmlWindow      "self._setCallbackInfo(self, HtmlWindow); self._setOORInfo(self)"
    %pythonAppend wxPyHtmlWindow()    ""
    %typemap(out) wxPyHtmlWindow*;    // turn off this typemap

    wxPyHtmlWindow(wxWindow *parent, int id = -1,
                 const wxPoint& pos = wxDefaultPosition,
                 const wxSize& size = wxDefaultSize,
                 int style=wxHW_DEFAULT_STYLE,
                 const wxString& name = wxPyHtmlWindowNameStr);
    %RenameCtor(PreHtmlWindow, wxPyHtmlWindow());

    // Turn it back on again
    %typemap(out) wxPyHtmlWindow* { $result = wxPyMake_wxObject($1, $owner); }

    bool Create(wxWindow *parent, int id = -1,
                const wxPoint& pos = wxDefaultPosition,
                const wxSize& size = wxDefaultSize,
                int style=wxHW_SCROLLBAR_AUTO,
                const wxString& name = wxPyHtmlWindowNameStr);


    void _setCallbackInfo(PyObject* self, PyObject* _class);


    // Set HTML page and display it. !! source is HTML document itself,
    // it is NOT address/filename of HTML document. If you want to
    // specify document location, use LoadPage() istead
    // Return value : False if an error occurred, True otherwise
    bool SetPage(const wxString& source);

    // Load HTML page from given location. Location can be either
    // a) /usr/wxGTK2/docs/html/wx.htm
    // b) http://www.somewhere.uk/document.htm
    // c) ftp://ftp.somesite.cz/pub/something.htm
    // In case there is no prefix (http:,ftp:), the method
    // will try to find it itself (1. local file, then http or ftp)
    // After the page is loaded, the method calls SetPage() to display it.
    // Note : you can also use path relative to previously loaded page
    // Return value : same as SetPage
    bool LoadPage(const wxString& location);

    // Loads HTML page from file
    bool LoadFile(const wxString& filename);

    // Append to current page
    bool AppendToPage(const wxString& source);

     // Returns full location of opened page
    wxString GetOpenedPage();

    // Returns anchor within opened page
    wxString GetOpenedAnchor();

    // Returns <TITLE> of opened page or empty string otherwise
    wxString GetOpenedPageTitle();

    // Sets frame in which page title will  be displayed. Format is format of
    // frame title, e.g. "HtmlHelp : %s". It must contain exactly one %s
    void SetRelatedFrame(wxFrame* frame, const wxString& format);
    wxFrame* GetRelatedFrame();

    // After(!) calling SetRelatedFrame, this sets statusbar slot where messages
    // will be displayed. Default is -1 = no messages.
    void SetRelatedStatusBar(int bar);

    // Sets fonts to be used when displaying HTML page.
    %extend {
        void SetFonts(wxString normal_face, wxString fixed_face, PyObject* sizes=NULL) {
            int* temp = NULL;
            if (sizes) temp = int_LIST_helper(sizes);
            self->SetFonts(normal_face, fixed_face, temp);
            if (temp)
                delete [] temp;
        }
    }

    // Sets font sizes to be relative to the given size or the system
    // default size; use either specified or default font
    void SetStandardFonts(int size = -1,
                          const wxString& normal_face = wxPyEmptyString,
                          const wxString& fixed_face = wxPyEmptyString);

    DocDeclStr(
        void, SetLabel(const wxString& title),
        "", "");

    // Sets space between text and window borders.
    void SetBorders(int b);

    // Sets the bitmap to use for background (currnetly it will be tiled,
    // when/if we have CSS support we could add other possibilities...)
    void SetBackgroundImage(const wxBitmap& bmpBg);

    // Saves custom settings into cfg config. it will use the path 'path'
    // if given, otherwise it will save info into currently selected path.
    // saved values : things set by SetFonts, SetBorders.
    void ReadCustomization(wxConfigBase *cfg, wxString path = wxPyEmptyString);
    void WriteCustomization(wxConfigBase *cfg, wxString path = wxPyEmptyString);

    // Goes to previous/next page (in browsing history)
    // Returns True if successful, False otherwise
    bool HistoryBack();
    bool HistoryForward();
    bool HistoryCanBack();
    bool HistoryCanForward();

    // Resets History
    void HistoryClear();

    // Returns pointer to conteiners/cells structure.
    wxHtmlContainerCell* GetInternalRepresentation();

    // Returns a pointer to the parser.
    wxHtmlWinParser* GetParser();

    bool ScrollToAnchor(const wxString& anchor);
    bool HasAnchor(const wxString& anchor);

    //Adds input filter
    static void AddFilter(wxPyHtmlFilter *filter);

    // Helper functions to select parts of page:
    void SelectWord(const wxPoint& pos);
    void SelectLine(const wxPoint& pos);
    void SelectAll();

    // Convert selection to text:
    wxString SelectionToText();

    // Converts current page to text:
    wxString ToText();

    void OnLinkClicked(const wxHtmlLinkInfo& link);
    void OnSetTitle(const wxString& title);
    void OnCellMouseHover(wxHtmlCell *cell, wxCoord x, wxCoord y);
    void OnCellClicked(wxHtmlCell *cell,
                       wxCoord x, wxCoord y,
                       const wxMouseEvent& event);
    %MAKE_BASE_FUNC(HtmlWindow, OnLinkClicked);
    %MAKE_BASE_FUNC(HtmlWindow, OnSetTitle);
    %MAKE_BASE_FUNC(HtmlWindow, OnCellMouseHover);
    %MAKE_BASE_FUNC(HtmlWindow, OnCellClicked);

    static wxVisualAttributes
    GetClassDefaultAttributes(wxWindowVariant variant = wxWINDOW_VARIANT_NORMAL);
};




//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
%newgroup


MustHaveApp(wxHtmlDCRenderer);

class wxHtmlDCRenderer : public wxObject {
public:
    wxHtmlDCRenderer();
    ~wxHtmlDCRenderer();

    void SetDC(wxDC *dc, int maxwidth);
    void SetSize(int width, int height);
    void SetHtmlText(const wxString& html,
                     const wxString& basepath = wxPyEmptyString,
                     bool isdir = true);
    // Sets fonts to be used when displaying HTML page. (if size null then default sizes used).
    %extend {
        void SetFonts(wxString normal_face, wxString fixed_face, PyObject* sizes=NULL) {
            int* temp = NULL;
            if (sizes) temp = int_LIST_helper(sizes);
            self->SetFonts(normal_face, fixed_face, temp);
            if (temp)
                delete [] temp;
        }
    }

    // Sets font sizes to be relative to the given size or the system
    // default size; use either specified or default font
    void SetStandardFonts(int size = -1,
                          const wxString& normal_face = wxPyEmptyString,
                          const wxString& fixed_face = wxPyEmptyString);

    int Render(int x, int y, int from = 0, int dont_render = false, int maxHeight = INT_MAX,
               //int *known_pagebreaks = NULL, int number_of_pages = 0
               int* choices=NULL, int LCOUNT = 0
               );
    int GetTotalHeight();
                // returns total height of the html document
                // (compare Render's return value with this)
};


enum {
    wxPAGE_ODD,
    wxPAGE_EVEN,
    wxPAGE_ALL
};


MustHaveApp(wxHtmlPrintout);

class wxHtmlPrintout : public wxPyPrintout {
public:
    wxHtmlPrintout(const wxString& title = wxPyHtmlPrintoutTitleStr);
    //~wxHtmlPrintout();   wxPrintPreview object takes ownership...

    void SetHtmlText(const wxString& html,
                     const wxString &basepath = wxPyEmptyString,
                     bool isdir = true);
    void SetHtmlFile(const wxString &htmlfile);
    void SetHeader(const wxString& header, int pg = wxPAGE_ALL);
    void SetFooter(const wxString& footer, int pg = wxPAGE_ALL);

    // Sets fonts to be used when displaying HTML page. (if size null then default sizes used).
    %extend {
        void SetFonts(wxString normal_face, wxString fixed_face, PyObject* sizes=NULL) {
            int* temp = NULL;
            if (sizes) temp = int_LIST_helper(sizes);
            self->SetFonts(normal_face, fixed_face, temp);
            if (temp)
                delete [] temp;
        }
    }

    // Sets font sizes to be relative to the given size or the system
    // default size; use either specified or default font
    void SetStandardFonts(int size = -1,
                          const wxString& normal_face = wxPyEmptyString,
                          const wxString& fixed_face = wxPyEmptyString);

    void SetMargins(float top = 25.2, float bottom = 25.2,
                    float left = 25.2, float right = 25.2,
                    float spaces = 5);

    // Adds input filter
    static void AddFilter(wxHtmlFilter *filter);

    // Cleanup
    static void CleanUpStatics();
};



MustHaveApp(wxHtmlEasyPrinting);

class wxHtmlEasyPrinting : public wxObject {
public:
    wxHtmlEasyPrinting(const wxString& name = wxPyHtmlPrintingTitleStr,
                       wxWindow *parentWindow = NULL);
    ~wxHtmlEasyPrinting();

    void PreviewFile(const wxString &htmlfile);
    void PreviewText(const wxString &htmltext, const wxString& basepath = wxPyEmptyString);
    void PrintFile(const wxString &htmlfile);
    void PrintText(const wxString &htmltext, const wxString& basepath = wxPyEmptyString);
//    void PrinterSetup();
    void PageSetup();
    void SetHeader(const wxString& header, int pg = wxPAGE_ALL);
    void SetFooter(const wxString& footer, int pg = wxPAGE_ALL);

    %extend {
        void SetFonts(wxString normal_face, wxString fixed_face, PyObject* sizes=NULL) {
            int* temp = NULL;
            if (sizes) temp = int_LIST_helper(sizes);
            self->SetFonts(normal_face, fixed_face, temp);
            if (temp)
                delete [] temp;
        }
    }

    // Sets font sizes to be relative to the given size or the system
    // default size; use either specified or default font
    void SetStandardFonts(int size = -1,
                          const wxString& normal_face = wxPyEmptyString,
                          const wxString& fixed_face = wxPyEmptyString);

    wxPrintData *GetPrintData() {return m_PrintData;}
    wxPageSetupDialogData *GetPageSetupData() {return m_PageSetupData;}

};


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
%newgroup


class wxHtmlBookRecord {
public:
    wxHtmlBookRecord(const wxString& bookfile, const wxString& basepath,
                     const wxString& title, const wxString& start);

    wxString GetBookFile();
    wxString GetTitle();
    wxString GetStart();
    wxString GetBasePath();

    void SetContentsRange(int start, int end);
    int GetContentsStart();
    int GetContentsEnd();

    void SetTitle(const wxString& title);
    void SetBasePath(const wxString& path);
    void SetStart(const wxString& start);

    wxString GetFullPath(const wxString &page) const;
};

//---------------------------------------------------------------------------
// WXWIN_COMPATIBILITY_2_4
#if 0
struct wxHtmlContentsItem
{
    %extend {
        int GetLevel() { return self->m_Level; }
        int GetID() { return self->m_ID; }
        wxString GetName() { return self->m_Name; }
        wxString GetPage() { return self->m_Page; }
        wxHtmlBookRecord* GetBook() { return self->m_Book; }
    }
};
#endif
//---------------------------------------------------------------------------

class wxHtmlSearchStatus
{
public:
    //wxHtmlSearchStatus(wxHtmlHelpData* base, const wxString& keyword,
    //                   const wxString& book = wxPyEmptyString);
    bool Search();
    bool IsActive();
    int GetCurIndex();
    int GetMaxIndex();
    const wxString& GetName();
    // WXWIN_COMPATIBILITY_2_4
#if 0
    wxHtmlContentsItem* GetContentsItem();
#endif
};

//---------------------------------------------------------------------------

class wxHtmlHelpData {
public:
    wxHtmlHelpData();
    ~wxHtmlHelpData();

    void SetTempDir(const wxString& path);
    bool AddBook(const wxString& book);
//      bool AddBookParam(const wxString& title, const wxString& contfile,
//  		      const wxString& indexfile=wxPyEmptyString,
//  		      const wxString& deftopic=wxPyEmptyString,
//  		      const wxString& path=wxPyEmptyString);

    wxString FindPageByName(const wxString& page);
    wxString FindPageById(int id);

    // TODO: this one needs fixed...
    const wxHtmlBookRecArray& GetBookRecArray();

    // WXWIN_COMPATIBILITY_2_4
#if 0
    wxHtmlContentsItem* GetContents();
    int GetContentsCnt();
    wxHtmlContentsItem* GetIndex();
    int GetIndexCnt();
#endif
};

//---------------------------------------------------------------------------

enum {
    wxHF_TOOLBAR,
    wxHF_CONTENTS,
    wxHF_INDEX,
    wxHF_SEARCH,
    wxHF_BOOKMARKS,
    wxHF_OPEN_FILES,
    wxHF_PRINT,
    wxHF_FLAT_TOOLBAR,
    wxHF_MERGE_BOOKS,
    wxHF_ICONS_BOOK,
    wxHF_ICONS_BOOK_CHAPTER,
    wxHF_ICONS_FOLDER,
    wxHF_DEFAULT_STYLE,

    wxHF_EMBEDDED,
    wxHF_DIALOG,
    wxHF_FRAME,
    wxHF_MODAL,
};

enum {
    wxID_HTML_PANEL,
    wxID_HTML_BACK,
    wxID_HTML_FORWARD,
    wxID_HTML_UPNODE,
    wxID_HTML_UP,
    wxID_HTML_DOWN,
    wxID_HTML_PRINT,
    wxID_HTML_OPENFILE,
    wxID_HTML_OPTIONS,
    wxID_HTML_BOOKMARKSLIST,
    wxID_HTML_BOOKMARKSADD,
    wxID_HTML_BOOKMARKSREMOVE,
    wxID_HTML_TREECTRL,
    wxID_HTML_INDEXPAGE,
    wxID_HTML_INDEXLIST,
    wxID_HTML_INDEXTEXT,
    wxID_HTML_INDEXBUTTON,
    wxID_HTML_INDEXBUTTONALL,
    wxID_HTML_NOTEBOOK,
    wxID_HTML_SEARCHPAGE,
    wxID_HTML_SEARCHTEXT,
    wxID_HTML_SEARCHLIST,
    wxID_HTML_SEARCHBUTTON,
    wxID_HTML_SEARCHCHOICE,
    wxID_HTML_COUNTINFO
};    



MustHaveApp(wxHtmlHelpWindow);

class wxHtmlHelpWindow : public wxWindow
{
public:
    %pythonAppend wxHtmlHelpWindow    "self._setOORInfo(self)"
    %pythonAppend wxHtmlHelpWindow()       ""
    %typemap(out) wxHtmlHelpWindow*;    // turn off this typemap

    wxHtmlHelpWindow(wxWindow* parent, wxWindowID wxWindowID,
                     const wxPoint& pos = wxDefaultPosition,
                     const wxSize& size = wxDefaultSize,
                     int style = wxTAB_TRAVERSAL|wxNO_BORDER,
                     int helpStyle = wxHF_DEFAULT_STYLE,
                     wxHtmlHelpData* data = NULL);
    %RenameCtor(PreHtmlHelpWindow, wxHtmlHelpWindow(wxHtmlHelpData* data = NULL));
    
    // Turn it back on again
    %typemap(out) wxHtmlHelpWindow* { $result = wxPyMake_wxObject($1, $owner); }

    bool Create(wxWindow* parent, wxWindowID id,
                const wxPoint& pos = wxDefaultPosition,
                const wxSize& size = wxDefaultSize,
                int style = wxTAB_TRAVERSAL|wxNO_BORDER,
                int helpStyle = wxHF_DEFAULT_STYLE);

    wxHtmlHelpData* GetData();
    wxHtmlHelpController* GetController() const;

    %disownarg( wxHtmlHelpController* controller );
    void SetController(wxHtmlHelpController* controller);
    %cleardisown( wxHtmlHelpController* controller );

    // Displays page x. If not found it will offect the user a choice of
    // searching books.
    // Looking for the page runs in these steps:
    // 1. try to locate file named x (if x is for example "doc/howto.htm")
    // 2. try to open starting page of book x
    // 3. try to find x in contents (if x is for example "How To ...")
    // 4. try to find x in index (if x is for example "How To ...")
    bool Display(const wxString& x);

    // Alternative version that works with numeric ID.
    // (uses extension to MS format, <param name="ID" value=id>, see docs)
    %Rename(DisplayID,  bool,  Display(int id));

    // Displays help window and focuses contents.
    bool DisplayContents();

    // Displays help window and focuses index.
    bool DisplayIndex();

    // Searches for keyword. Returns true and display page if found, return
    // false otherwise
    // Syntax of keyword is Altavista-like:
    // * words are separated by spaces
    //   (but "\"hello world\"" is only one world "hello world")
    // * word may be pretended by + or -
    //   (+ : page must contain the word ; - : page can't contain the word)
    // * if there is no + or - before the word, + is default
    bool KeywordSearch(const wxString& keyword,
                       wxHelpSearchMode mode = wxHELP_SEARCH_ALL);

    void UseConfig(wxConfigBase *config, const wxString& rootpath = wxEmptyString);

    // Saves custom settings into cfg config. it will use the path 'path'
    // if given, otherwise it will save info into currently selected path.
    // saved values : things set by SetFonts, SetBorders.
    void ReadCustomization(wxConfigBase *cfg, const wxString& path = wxEmptyString);
    void WriteCustomization(wxConfigBase *cfg, const wxString& path = wxEmptyString);

    // call this to let wxHtmlHelpWindow know page changed
    void NotifyPageChanged();

    // Refreshes Contents and Index tabs
    void RefreshLists();

    // Gets the HTML window
    wxHtmlWindow* GetHtmlWindow() const;

    // Gets the splitter window
    wxSplitterWindow* GetSplitterWindow();

    // Gets the toolbar
    wxToolBar* GetToolBar() const;

    // Gets the configuration data
    wxHtmlHelpFrameCfg& GetCfgData();

    // Gets the tree control
    wxTreeCtrl *GetTreeCtrl() const;

};


class wxHtmlWindowEvent: public wxNotifyEvent
{
public:
    wxHtmlWindowEvent(wxEventType commandType = wxEVT_NULL, int id = 0):
        wxNotifyEvent(commandType, id);

    void SetURL(const wxString& url);
    const wxString& GetURL() const;
};



MustHaveApp(wxHtmlHelpFrame);

class wxHtmlHelpFrame : public wxFrame {
public:
    %pythonAppend wxHtmlHelpFrame    "self._setOORInfo(self)"
    %pythonAppend wxHtmlHelpFrame()       ""
    %typemap(out) wxHtmlHelpFrame*;    // turn off this typemap

    wxHtmlHelpFrame(wxWindow* parent, int wxWindowID,
		    const wxString& title = wxPyEmptyString,
		    int style = wxHF_DEFAULTSTYLE, wxHtmlHelpData* data = NULL);
    %RenameCtor(PreHtmlHelpFrame, wxHtmlHelpFrame(wxHtmlHelpData* data = NULL));

    // Turn it back on again
    %typemap(out) wxHtmlHelpFrame* { $result = wxPyMake_wxObject($1, $owner); }
    
    bool Create(wxWindow* parent, wxWindowID id,
                const wxString& title = wxPyEmptyString,
                int style = wxHF_DEFAULT_STYLE);

    wxHtmlHelpData* GetData();
    void SetTitleFormat(const wxString& format);

    void AddGrabIfNeeded();

    /// Returns the help controller associated with the window.
    wxHtmlHelpController* GetController() const;

    /// Sets the help controller associated with the window.
    %disownarg( wxHtmlHelpController* controller );
    void SetController(wxHtmlHelpController* controller);
    %cleardisown( wxHtmlHelpController* controller );

    /// Returns the help window.
    wxHtmlHelpWindow* GetHelpWindow() const;

    %pythoncode {
        %# For compatibility from before the refactor
        def Display(self, x):
            return self.GetHelpWindow().Display(x)
        def DisplayID(self, x):
            return self.GetHelpWindow().DisplayID(id)
        def DisplayContents(self):
            return self.GetHelpWindow().DisplayContents()
        def DisplayIndex(self):
            return self.GetHelpWindow().DisplayIndex()

        def KeywordSearch(self, keyword):
            return self.GetHelpWindow().KeywordSearch(keyword)
             
        def UseConfig(self, config, rootpath=""):
            return self.GetHelpWindow().UseConfig(config, rootpath)
        def ReadCustomization(self, config, rootpath=""):
            return self.GetHelpWindow().ReadCustomization(config, rootpath)
        def WriteCustomization(self, config, rootpath=""):
            return self.GetHelpWindow().WriteCustomization(config, rootpath)
     %}
};



MustHaveApp(wxHtmlHelpDialog);

class wxHtmlHelpDialog : public wxDialog
{
public:
    %pythonAppend wxHtmlHelpDialog    "self._setOORInfo(self)"
    %pythonAppend wxHtmlHelpDialog()       ""
    %typemap(out) wxHtmlHelpDialog*;    // turn off this typemap

    wxHtmlHelpDialog(wxWindow* parent, wxWindowID wxWindowID,
                    const wxString& title = wxPyEmptyString,
                    int style = wxHF_DEFAULT_STYLE, wxHtmlHelpData* data = NULL);
    %RenameCtor(PreHtmlHelpDialog, wxHtmlHelpDialog(wxHtmlHelpData* data = NULL));

    // Turn it back on again
    %typemap(out) wxHtmlHelpDialog* { $result = wxPyMake_wxObject($1, $owner); }
    
    bool Create(wxWindow* parent, wxWindowID id, const wxString& title = wxPyEmptyString,
                int style = wxHF_DEFAULT_STYLE);

    /// Returns the data associated with this dialog.
    wxHtmlHelpData* GetData();

    /// Returns the controller that created this dialog.
    wxHtmlHelpController* GetController() const;

    /// Sets the controller associated with this dialog.
    %disownarg( wxHtmlHelpController* controller );
    void SetController(wxHtmlHelpController* controller);
    %cleardisown( wxHtmlHelpController* controller );

    /// Returns the help window.
    wxHtmlHelpWindow* GetHelpWindow() const;

    // Sets format of title of the frame. Must contain exactly one "%s"
    // (for title of displayed HTML page)
    void SetTitleFormat(const wxString& format);

    // Override to add custom buttons to the toolbar
//    virtual void AddToolbarButtons(wxToolBar* WXUNUSED(toolBar), int WXUNUSED(style)) {};

};


//---------------------------------------------------------------------------


// TODO: Make virtual methods of this class overridable in Python.

MustHaveApp(wxHelpControllerBase);

class wxHelpControllerBase: public wxObject
{
public:
//    wxHelpControllerBase(wxWindow* parentWindow = NULL);
//    ~wxHelpControllerBase();

    %nokwargs Initialize;
    virtual bool Initialize(const wxString& file, int server );
    virtual bool Initialize(const wxString& file);

    virtual void SetViewer(const wxString& viewer, long flags = 0);

    // If file is "", reloads file given  in Initialize
    virtual bool LoadFile(const wxString& file = wxEmptyString) /* = 0 */;

    // Displays the contents
    virtual bool DisplayContents(void) /* = 0 */;

    %nokwargs DisplaySection;

    // Display the given section
    virtual bool DisplaySection(int sectionNo) /* = 0 */;

    // Display the section using a context id
    virtual bool DisplayContextPopup(int contextId);

    // Display the text in a popup, if possible
    virtual bool DisplayTextPopup(const wxString& text, const wxPoint& pos);

    // By default, uses KeywordSection to display a topic. Implementations
    // may override this for more specific behaviour.
    virtual bool DisplaySection(const wxString& section);

    virtual bool DisplayBlock(long blockNo) /* = 0 */;
    virtual bool KeywordSearch(const wxString& k,
                               wxHelpSearchMode mode = wxHELP_SEARCH_ALL) /* = 0 */;

    /// Allows one to override the default settings for the help frame.
    virtual void SetFrameParameters(const wxString& title,
                                    const wxSize& size,
                                    const wxPoint& pos = wxDefaultPosition,
                                    bool newFrameEachTime = false);

    /// Obtains the latest settings used by the help frame and the help
    /// frame.
    virtual wxFrame *GetFrameParameters(wxSize *size = NULL,
                                        wxPoint *pos = NULL,
                                        bool *newFrameEachTime = NULL);

    virtual bool Quit() /* = 0 */;

    virtual void OnQuit();

    /// Set the window that can optionally be used for the help window's parent.
    virtual void SetParentWindow(wxWindow* win);

    /// Get the window that can optionally be used for the help window's parent.
    virtual wxWindow* GetParentWindow() const;

};




MustHaveApp(wxHtmlHelpController);

class wxHtmlHelpController : public wxHelpControllerBase
{
public:
//    %pythonAppend wxHtmlHelpController "self._setOORInfo(self)"

    wxHtmlHelpController(int style = wxHF_DEFAULT_STYLE, wxWindow* parentWindow = NULL);
    ~wxHtmlHelpController();

    wxHtmlHelpWindow* GetHelpWindow();
    void SetHelpWindow(wxHtmlHelpWindow* helpWindow);

    wxHtmlHelpFrame* GetFrame();
    wxHtmlHelpDialog* GetDialog();

    void SetTitleFormat(const wxString& format);
    void SetTempDir(const wxString& path);
    bool AddBook(const wxString& book, int show_wait_msg = false);
    void Display(const wxString& x);
    %Rename(DisplayID,  void,  Display(int id));
    void DisplayContents();
    void DisplayIndex();
    bool KeywordSearch(const wxString& keyword);
    void UseConfig(wxConfigBase *config, const wxString& rootpath = wxPyEmptyString);
    void ReadCustomization(wxConfigBase *cfg, wxString path = wxPyEmptyString);
    void WriteCustomization(wxConfigBase *cfg, wxString path = wxPyEmptyString);

    void MakeModalIfNeeded();
    wxWindow* FindTopLevelWindow();
};


/*
 * wxHtmlModalHelp
 * A convenience class particularly for use on wxMac,
 * where you can only show modal dialogs from a modal
 * dialog.
 *
 * Use like this:
 *
 * wxHtmlModalHelp help(parent, filename, topic);
 *
 * If topic is empty, the help contents is displayed.
 */

class wxHtmlModalHelp
{
public:
    wxHtmlModalHelp(wxWindow* parent, const wxString& helpFile,
                    const wxString& topic = wxEmptyString,
                    int style = wxHF_DEFAULT_STYLE | wxHF_DIALOG | wxHF_MODAL);
};


//---------------------------------------------------------------------------
%init %{
    wxPyPtrTypeMap_Add("wxHtmlTagHandler",    "wxPyHtmlTagHandler");
    wxPyPtrTypeMap_Add("wxHtmlWinTagHandler", "wxPyHtmlWinTagHandler");
    wxPyPtrTypeMap_Add("wxHtmlWindow",        "wxPyHtmlWindow");
    wxPyPtrTypeMap_Add("wxHtmlFilter",        "wxPyHtmlFilter");
%}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------



