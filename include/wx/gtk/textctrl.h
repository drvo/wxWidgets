/////////////////////////////////////////////////////////////////////////////
// Name:        wx/gtk/textctrl.h
// Purpose:
// Author:      Robert Roebling
// Created:     01/02/97
// Id:          $Id$
// Copyright:   (c) 1998 Robert Roebling
// Licence:     wxWindows licence
/////////////////////////////////////////////////////////////////////////////

#ifndef __GTKTEXTCTRLH__
#define __GTKTEXTCTRLH__

#if defined(__GNUG__) && !defined(NO_GCC_PRAGMA)
    #pragma interface "textctrl.h"
#endif

//-----------------------------------------------------------------------------
// wxTextCtrl
//-----------------------------------------------------------------------------

class wxTextCtrl: public wxTextCtrlBase
{
public:
    wxTextCtrl() { Init(); }
    wxTextCtrl(wxWindow *parent,
               wxWindowID id,
               const wxString &value = wxEmptyString,
               const wxPoint &pos = wxDefaultPosition,
               const wxSize &size = wxDefaultSize,
               long style = 0,
               const wxValidator& validator = wxDefaultValidator,
               const wxString &name = wxTextCtrlNameStr);

    bool Create(wxWindow *parent,
                wxWindowID id,
                const wxString &value = wxEmptyString,
                const wxPoint &pos = wxDefaultPosition,
                const wxSize &size = wxDefaultSize,
                long style = 0,
                const wxValidator& validator = wxDefaultValidator,
                const wxString &name = wxTextCtrlNameStr);

    // implement base class pure virtuals
    // ----------------------------------

    virtual wxString GetValue() const;
    virtual void SetValue(const wxString& value);

    virtual int GetLineLength(long lineNo) const;
    virtual wxString GetLineText(long lineNo) const;
    virtual int GetNumberOfLines() const;

    virtual bool IsModified() const;
    virtual bool IsEditable() const;

    // If the return values from and to are the same, there is no selection.
    virtual void GetSelection(long* from, long* to) const;

    // operations
    // ----------

    // editing
    virtual void Clear();
    virtual void Replace(long from, long to, const wxString& value);
    virtual void Remove(long from, long to);

    // sets/clears the dirty flag
    virtual void MarkDirty();
    virtual void DiscardEdits();

    virtual void SetMaxLength(unsigned long len);

    // writing text inserts it at the current position, appending always
    // inserts it at the end
    virtual void WriteText(const wxString& text);
    virtual void AppendText(const wxString& text);

    // apply text attribute to the range of text (only works with richedit
    // controls)
    virtual bool SetStyle(long start, long end, const wxTextAttr& style);

    // translate between the position (which is just an index in the text ctrl
    // considering all its contents as a single strings) and (x, y) coordinates
    // which represent column and line.
    virtual long XYToPosition(long x, long y) const;
    virtual bool PositionToXY(long pos, long *x, long *y) const;

    virtual void ShowPosition(long pos);

#ifdef __WXGTK20__
    virtual wxTextCtrlHitTestResult HitTest(const wxPoint& pt, long *pos) const;
    virtual wxTextCtrlHitTestResult HitTest(const wxPoint& pt,
                                            wxTextCoord *col,
                                            wxTextCoord *row) const
    {
        return wxTextCtrlBase::HitTest(pt, col, row);
    }
#endif // __WXGTK20__

    // Clipboard operations
    virtual void Copy();
    virtual void Cut();
    virtual void Paste();

    // Undo/redo
    virtual void Undo();
    virtual void Redo();

    virtual bool CanUndo() const;
    virtual bool CanRedo() const;

    // Insertion point
    virtual void SetInsertionPoint(long pos);
    virtual void SetInsertionPointEnd();
    virtual long GetInsertionPoint() const;
    virtual wxTextPos GetLastPosition() const;

    virtual void SetSelection(long from, long to);
    virtual void SetEditable(bool editable);

    virtual bool Enable( bool enable = true );

    // Implementation from now on
    void OnDropFiles( wxDropFilesEvent &event );
    void OnChar( wxKeyEvent &event );

    void OnCut(wxCommandEvent& event);
    void OnCopy(wxCommandEvent& event);
    void OnPaste(wxCommandEvent& event);
    void OnUndo(wxCommandEvent& event);
    void OnRedo(wxCommandEvent& event);

    void OnUpdateCut(wxUpdateUIEvent& event);
    void OnUpdateCopy(wxUpdateUIEvent& event);
    void OnUpdatePaste(wxUpdateUIEvent& event);
    void OnUpdateUndo(wxUpdateUIEvent& event);
    void OnUpdateRedo(wxUpdateUIEvent& event);

    bool SetFont(const wxFont& font);
    bool SetForegroundColour(const wxColour& colour);
    bool SetBackgroundColour(const wxColour& colour);

    GtkWidget* GetConnectWidget();
    bool IsOwnGtkWindow( GdkWindow *window );
    void DoApplyWidgetStyle(GtkRcStyle *style);
    void CalculateScrollbar();
    void OnInternalIdle();

#ifdef __WXGTK20__
    void SetUpdateFont(bool WXUNUSED(update)) { }
#else // !__WXGTK20__
    void SetUpdateFont(bool update) { m_updateFont = update; }
    void UpdateFontIfNeeded();
#endif // __WXGTK20__/!__WXGTK20__

    void SetModified() { m_modified = true; }

    // GTK+ textctrl is so dumb that you need to freeze/thaw it manually to
    // avoid horrible flicker/scrolling back and forth
    virtual void Freeze();
    virtual void Thaw();

    // textctrl specific scrolling
    virtual bool ScrollLines(int lines);
    virtual bool ScrollPages(int pages);

    // implementation only from now on

    // wxGTK-specific: called recursively by Enable,
    // to give widgets an oppprtunity to correct their colours after they
    // have been changed by Enable
    virtual void OnParentEnable( bool enable ) ;

    // tell the control to ignore next text changed signal
    void IgnoreNextTextUpdate();

    // should we ignore the changed signal? always resets the flag
    bool IgnoreTextUpdate();

    static wxVisualAttributes
    GetClassDefaultAttributes(wxWindowVariant variant = wxWINDOW_VARIANT_NORMAL);

protected:
    virtual wxSize DoGetBestSize() const;

    // common part of all ctors
    void Init();

    // get the vertical adjustment, if any, NULL otherwise
    GtkAdjustment *GetVAdj() const;

    // scroll the control by the given number of pixels, return true if the
    // scroll position changed
    bool DoScroll(GtkAdjustment *adj, int diff);

    // Widgets that use the style->base colour for the BG colour should
    // override this and return true.
    virtual bool UseGTKStyleBase() const { return true; }

#ifdef __WXGTK20__
    // has the control been frozen by Freeze()?
    bool IsFrozen() const { return m_frozenness > 0; }
#endif

private:
    // change the font for everything in this control
    void ChangeFontGlobally();

    GtkWidget  *m_text;
    GtkWidget  *m_vScrollbar;

    bool        m_modified:1;
    bool        m_vScrollbarVisible:1;
#ifndef __WXGTK20__
    bool        m_updateFont:1;
#endif // !__WXGTK20__
    bool        m_ignoreNextUpdate:1;

#ifdef __WXGTK20__
    // Our text buffer. Convenient, and holds the buffer while using
    // a dummy one when m_frozenness > 0
    GtkTextBuffer *m_buffer;

    // number of calls to Freeze() minus number of calls to Thaw()
    unsigned int m_frozenness;
#endif

    DECLARE_EVENT_TABLE()
    DECLARE_DYNAMIC_CLASS(wxTextCtrl);
};

#endif // __GTKTEXTCTRLH__

