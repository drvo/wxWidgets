///////////////////////////////////////////////////////////////////////////////
// Name:        msw/checklst.cpp
// Purpose:     implementation of wxCheckListBox class
// Author:      Vadim Zeitlin
// Modified by:
// Created:     16.11.97
// RCS-ID:      $Id$
// Copyright:   (c) 1998 Vadim Zeitlin <zeitlin@dptmaths.ens-cachan.fr>
// Licence:     wxWindows licence
///////////////////////////////////////////////////////////////////////////////

// ============================================================================
// declarations
// ============================================================================

// ----------------------------------------------------------------------------
// headers
// ----------------------------------------------------------------------------

#if defined(__GNUG__) && !defined(NO_GCC_PRAGMA)
#pragma implementation "checklst.h"
#endif

// For compilers that support precompilation, includes "wx.h".
#include "wx/wxprec.h"

#ifdef __BORLANDC__
#pragma hdrstop
#endif

#if wxUSE_OWNER_DRAWN

#ifndef WX_PRECOMP
    #include "wx/object.h"
    #include "wx/colour.h"
    #include "wx/font.h"
    #include "wx/bitmap.h"
    #include "wx/window.h"
    #include "wx/listbox.h"
    #include "wx/dcmemory.h"

    #include "wx/settings.h"

    #include "wx/log.h"
#endif

#include "wx/ownerdrw.h"
#include "wx/checklst.h"

#include "wx/msw/wrapwin.h"
#include <windowsx.h>

#include "wx/msw/private.h"

#if defined(__GNUWIN32_OLD__)
    #include "wx/msw/gnuwin32/extra.h"
#endif

// ----------------------------------------------------------------------------
// private functions
// ----------------------------------------------------------------------------

// get item (converted to right type)
#define GetItem(n)    ((wxCheckListBoxItem *)(GetItem(n)))

// ============================================================================
// implementation of wxCheckListBoxBase
// ============================================================================

wxCheckListBoxBase::wxCheckListBoxBase()
{
}

// ============================================================================
// implementation of wxCheckListBox
// ============================================================================


#if wxUSE_EXTENDED_RTTI
WX_DEFINE_FLAGS( wxCheckListBoxStyle )

wxBEGIN_FLAGS( wxCheckListBoxStyle )
    // new style border flags, we put them first to
    // use them for streaming out
    wxFLAGS_MEMBER(wxBORDER_SIMPLE)
    wxFLAGS_MEMBER(wxBORDER_SUNKEN)
    wxFLAGS_MEMBER(wxBORDER_DOUBLE)
    wxFLAGS_MEMBER(wxBORDER_RAISED)
    wxFLAGS_MEMBER(wxBORDER_STATIC)
    wxFLAGS_MEMBER(wxBORDER_NONE)
    
    // old style border flags
    wxFLAGS_MEMBER(wxSIMPLE_BORDER)
    wxFLAGS_MEMBER(wxSUNKEN_BORDER)
    wxFLAGS_MEMBER(wxDOUBLE_BORDER)
    wxFLAGS_MEMBER(wxRAISED_BORDER)
    wxFLAGS_MEMBER(wxSTATIC_BORDER)
    wxFLAGS_MEMBER(wxBORDER)

    // standard window styles
    wxFLAGS_MEMBER(wxTAB_TRAVERSAL)
    wxFLAGS_MEMBER(wxCLIP_CHILDREN)
    wxFLAGS_MEMBER(wxTRANSPARENT_WINDOW)
    wxFLAGS_MEMBER(wxWANTS_CHARS)
    wxFLAGS_MEMBER(wxFULL_REPAINT_ON_RESIZE)
    wxFLAGS_MEMBER(wxALWAYS_SHOW_SB )
    wxFLAGS_MEMBER(wxVSCROLL)
    wxFLAGS_MEMBER(wxHSCROLL)

    wxFLAGS_MEMBER(wxLB_SINGLE)
    wxFLAGS_MEMBER(wxLB_MULTIPLE)
    wxFLAGS_MEMBER(wxLB_EXTENDED)
    wxFLAGS_MEMBER(wxLB_HSCROLL)
    wxFLAGS_MEMBER(wxLB_ALWAYS_SB)
    wxFLAGS_MEMBER(wxLB_NEEDED_SB)
    wxFLAGS_MEMBER(wxLB_SORT)
    wxFLAGS_MEMBER(wxLB_OWNERDRAW)

wxEND_FLAGS( wxCheckListBoxStyle )

IMPLEMENT_DYNAMIC_CLASS_XTI(wxCheckListBox, wxListBox,"wx/checklst.h")

wxBEGIN_PROPERTIES_TABLE(wxCheckListBox)
	wxEVENT_PROPERTY( Toggle , wxEVT_COMMAND_CHECKLISTBOX_TOGGLED , wxCommandEvent )
    wxPROPERTY_FLAGS( WindowStyle , wxCheckListBoxStyle , long , SetWindowStyleFlag , GetWindowStyleFlag , , wxLB_OWNERDRAW /*flags*/ , wxT("Helpstring") , wxT("group")) // style
wxEND_PROPERTIES_TABLE()

wxBEGIN_HANDLERS_TABLE(wxCheckListBox)
wxEND_HANDLERS_TABLE()

wxCONSTRUCTOR_4( wxCheckListBox , wxWindow* , Parent , wxWindowID , Id , wxPoint , Position , wxSize , Size ) 

#else
IMPLEMENT_DYNAMIC_CLASS(wxCheckListBox, wxListBox)
#endif

// ----------------------------------------------------------------------------
// declaration and implementation of wxCheckListBoxItem class
// ----------------------------------------------------------------------------

class wxCheckListBoxItem : public wxOwnerDrawn
{
friend class WXDLLEXPORT wxCheckListBox;
public:
  // ctor
  wxCheckListBoxItem(wxCheckListBox *pParent, size_t nIndex);

  // drawing functions
  virtual bool OnDrawItem(wxDC& dc, const wxRect& rc, wxODAction act, wxODStatus stat);

  // simple accessors and operations
  bool IsChecked() const { return m_bChecked; }

  void Check(bool bCheck);
  void Toggle() { Check(!IsChecked()); }

  void SendEvent();

private:

    DECLARE_NO_COPY_CLASS(wxCheckListBoxItem)
  bool            m_bChecked;
  wxCheckListBox *m_pParent;
  size_t          m_nIndex;
};

wxCheckListBoxItem::wxCheckListBoxItem(wxCheckListBox *pParent, size_t nIndex)
                  : wxOwnerDrawn(wxEmptyString, TRUE)   // checkable
{
  m_bChecked = FALSE;
  m_pParent  = pParent;
  m_nIndex   = nIndex;

  // we don't initialize m_nCheckHeight/Width vars because it's
  // done in OnMeasure while they are used only in OnDraw and we
  // know that there will always be OnMeasure before OnDraw

  // fix appearance
  SetMarginWidth(GetDefaultMarginWidth());
}

/*
 * JACS - I've got the owner-draw stuff partially working with WIN16,
 * with a really horrible-looking cross for wxCheckListBox instead of a
 * check - could use a bitmap check-mark instead, defined in wx.rc.
 * Also there's a refresh problem whereby it doesn't always draw the
 * check until you click to the right of it, which is OK for WIN32.
 */

bool wxCheckListBoxItem::OnDrawItem(wxDC& dc, const wxRect& rc,
                                    wxODAction act, wxODStatus stat)
{
  if ( IsChecked() )
    stat = (wxOwnerDrawn::wxODStatus)(stat | wxOwnerDrawn::wxODChecked);

  if ( wxOwnerDrawn::OnDrawItem(dc, rc, act, stat) ) {
    // ## using native API for performance and precision
    size_t nCheckWidth  = GetDefaultMarginWidth(),
         nCheckHeight = m_pParent->GetItemHeight();

    int x = rc.GetX(),
        y = rc.GetY();

    HDC hdc = (HDC)dc.GetHDC();

    // create pens
    HPEN hpenBack = CreatePen(PS_SOLID, 0, GetSysColor(COLOR_WINDOW)),
         hpenGray = CreatePen(PS_SOLID, 0, RGB(128, 128, 128)),
         hpenPrev = (HPEN)SelectObject(hdc, hpenBack);

    // we erase the 1-pixel border
    Rectangle(hdc, x, y, x + nCheckWidth, y + nCheckHeight);

    // shift check mark 1 pixel to the right (it looks better like this)
    x++;

    if ( IsChecked() ) {
      // first create a monochrome bitmap in a memory DC
      HDC hdcMem = CreateCompatibleDC(hdc);
      HBITMAP hbmpCheck = CreateBitmap(nCheckWidth, nCheckHeight, 1, 1, 0);
      HBITMAP hbmpOld = (HBITMAP)SelectObject(hdcMem, hbmpCheck);

      // then draw a check mark into it

      RECT rect;
      rect.left   = 0;
      rect.top    = 0;
      rect.right  = nCheckWidth;
      rect.bottom = nCheckHeight;

#ifdef __WXWINCE__
      DrawFrameControl(hdcMem, &rect, DFC_BUTTON, DFCS_BUTTONCHECK);
#else
      DrawFrameControl(hdcMem, &rect, DFC_MENU, DFCS_MENUCHECK);
#endif

      // finally copy it to screen DC and clean up
      BitBlt(hdc, x, y, nCheckWidth - 1, nCheckHeight,
             hdcMem, 0, 0, SRCCOPY);

      SelectObject(hdcMem, hbmpOld);
      DeleteObject(hbmpCheck);
      DeleteDC(hdcMem);
    }

    // now we draw the smaller rectangle
    y++;
    nCheckWidth  -= 2;
    nCheckHeight -= 2;

    // draw hollow gray rectangle
    (void)SelectObject(hdc, hpenGray);
    HBRUSH hbrPrev  = (HBRUSH)SelectObject(hdc, GetStockObject(NULL_BRUSH));
    Rectangle(hdc, x, y, x + nCheckWidth, y + nCheckHeight);

    // clean up
    (void)SelectObject(hdc, hpenPrev);
    (void)SelectObject(hdc, hbrPrev);

    DeleteObject(hpenBack);
    DeleteObject(hpenGray);

    /*
    dc.DrawRectangle(x, y, nCheckWidth, nCheckHeight);

    if ( IsChecked() ) {
      dc.DrawLine(x, y, x + nCheckWidth, y + nCheckHeight);
      dc.DrawLine(x, y + nCheckHeight, x + nCheckWidth, y);
    }
    */

    return TRUE;
  }

  return FALSE;
}

// change the state of the item and redraw it
void wxCheckListBoxItem::Check(bool check)
{
    m_bChecked = check;

    // index may be changed because new items were added/deleted
    if ( m_pParent->GetItemIndex(this) != (int)m_nIndex )
    {
        // update it
        int index = m_pParent->GetItemIndex(this);

        wxASSERT_MSG( index != wxNOT_FOUND, wxT("what does this item do here?") );

        m_nIndex = (size_t)index;
    }

    HWND hwndListbox = (HWND)m_pParent->GetHWND();

    #ifdef __WIN32__
        RECT rcUpdate;

        if ( ::SendMessage(hwndListbox, LB_GETITEMRECT,
                           m_nIndex, (LPARAM)&rcUpdate) == LB_ERR )
        {
            wxLogDebug(wxT("LB_GETITEMRECT failed"));
        }
    #else // Win16
        // FIXME this doesn't work if the listbox is scrolled!
        size_t nHeight = m_pParent->GetItemHeight();
        size_t y = m_nIndex * nHeight;
        RECT rcUpdate ;
        rcUpdate.left   = 0 ;
        rcUpdate.top    = y ;
        rcUpdate.right  = GetDefaultMarginWidth() ;
        rcUpdate.bottom = y + nHeight ;
    #endif  // Win32/16

    InvalidateRect(hwndListbox, &rcUpdate, FALSE);
}

// send an "item checked" event
void wxCheckListBoxItem::SendEvent()
{
    wxCommandEvent event(wxEVT_COMMAND_CHECKLISTBOX_TOGGLED, m_pParent->GetId());
    event.SetInt(m_nIndex);
    event.SetEventObject(m_pParent);
    m_pParent->ProcessCommand(event);
}

// ----------------------------------------------------------------------------
// implementation of wxCheckListBox class
// ----------------------------------------------------------------------------

// define event table
// ------------------
BEGIN_EVENT_TABLE(wxCheckListBox, wxListBox)
  EVT_KEY_DOWN(wxCheckListBox::OnKeyDown)
  EVT_LEFT_DOWN(wxCheckListBox::OnLeftClick)
END_EVENT_TABLE()

// control creation
// ----------------

// def ctor: use Create() to really create the control
wxCheckListBox::wxCheckListBox()
{
}

// ctor which creates the associated control
wxCheckListBox::wxCheckListBox(wxWindow *parent, wxWindowID id,
                               const wxPoint& pos, const wxSize& size,
                               int nStrings, const wxString choices[],
                               long style, const wxValidator& val,
                               const wxString& name)
{
    Create(parent, id, pos, size, nStrings, choices, style, val, name);
}

bool wxCheckListBox::Create(wxWindow *parent, wxWindowID id,
                            const wxPoint& pos, const wxSize& size,
                            int n, const wxString choices[],
                            long style,
                            const wxValidator& validator, const wxString& name)
{
    return wxListBox::Create(parent, id, pos, size, n, choices,
                             style | wxLB_OWNERDRAW, validator, name);
}

// misc overloaded methods
// -----------------------

void wxCheckListBox::Delete(int N)
{
    wxCHECK_RET( N >= 0 && N < m_noItems,
                 wxT("invalid index in wxListBox::Delete") );

    wxListBox::Delete(N);

    // free memory
    delete m_aItems[N];

    m_aItems.RemoveAt(N);
}

bool wxCheckListBox::SetFont( const wxFont &font )
{
    size_t i;
    for ( i = 0; i < m_aItems.GetCount(); i++ )
        m_aItems[i]->SetFont(font);

    wxListBox::SetFont(font);

    return TRUE;
}

// create/retrieve item
// --------------------

// create a check list box item
wxOwnerDrawn *wxCheckListBox::CreateLboxItem(size_t nIndex)
{
  wxCheckListBoxItem *pItem = new wxCheckListBoxItem(this, nIndex);
  return pItem;
}

// return item size
// ----------------
bool wxCheckListBox::MSWOnMeasure(WXMEASUREITEMSTRUCT *item)
{
  if ( wxListBox::MSWOnMeasure(item) ) {
    MEASUREITEMSTRUCT *pStruct = (MEASUREITEMSTRUCT *)item;

    // save item height
    m_nItemHeight = pStruct->itemHeight;

    // add place for the check mark
    pStruct->itemWidth += wxOwnerDrawn::GetDefaultMarginWidth();

    return TRUE;
  }

  return FALSE;
}

// check items
// -----------

bool wxCheckListBox::IsChecked(size_t uiIndex) const
{
    wxCHECK_MSG( uiIndex < (size_t)GetCount(), FALSE, _T("bad wxCheckListBox index") );

    return GetItem(uiIndex)->IsChecked();
}

void wxCheckListBox::Check(size_t uiIndex, bool bCheck)
{
    wxCHECK_RET( uiIndex < (size_t)GetCount(), _T("bad wxCheckListBox index") );

    GetItem(uiIndex)->Check(bCheck);
}

// process events
// --------------

void wxCheckListBox::OnKeyDown(wxKeyEvent& event)
{
    // what do we do?
    enum
    {
        None,
        Toggle,
        Set,
        Clear
    } oper;

    switch ( event.GetKeyCode() )
    {
        case WXK_SPACE:
            oper = Toggle;
            break;

        case WXK_NUMPAD_ADD:
        case '+':
            oper = Set;
            break;

        case WXK_NUMPAD_SUBTRACT:
        case '-':
            oper = Clear;
            break;

        default:
            oper = None;
    }

    if ( oper != None )
    {
        wxArrayInt selections;
        int count = 0;
        if ( HasMultipleSelection() )
        {
            count = GetSelections(selections);
        }
        else
        {
            int sel = GetSelection();
            if (sel != -1)
            {
                count = 1;
                selections.Add(sel);
            }
        }

        for ( int i = 0; i < count; i++ )
        {
            wxCheckListBoxItem *item = GetItem(selections[i]);
            if ( !item )
            {
                wxFAIL_MSG( _T("no wxCheckListBoxItem?") );
                continue;
            }

            switch ( oper )
            {
                case Toggle:
                    item->Toggle();
                    break;

                case Set:
                case Clear:
                    item->Check( oper == Set );
                    break;

                default:
                    wxFAIL_MSG( _T("what should this key do?") );
            }

            // we should send an event as this has been done by the user and
            // not by the program
            item->SendEvent();
        }
    }
    else // nothing to do
    {
        event.Skip();
    }
}

void wxCheckListBox::OnLeftClick(wxMouseEvent& event)
{
  // clicking on the item selects it, clicking on the checkmark toggles
  if ( event.GetX() <= wxOwnerDrawn::GetDefaultMarginWidth() ) {
    int nItem = HitTest(event.GetX(), event.GetY());

    if ( nItem != wxNOT_FOUND ) {
      wxCheckListBoxItem *item = GetItem(nItem);
      item->Toggle();
      item->SendEvent();
    }
    //else: it's not an error, just click outside of client zone
  }
  else {
    // implement default behaviour: clicking on the item selects it
    event.Skip();
  }
}

int wxCheckListBox::DoHitTestItem(wxCoord x, wxCoord y) const
{
  #ifdef __WIN32__
    int nItem = (int)::SendMessage
                             (
                              (HWND)GetHWND(),
                              LB_ITEMFROMPOINT,
                              0,
                              MAKELPARAM(x, y)
                             );
  #else // Win16
    // FIXME this doesn't work when the listbox is scrolled!
    int nItem = y / m_nItemHeight;
  #endif // Win32/16

  return nItem >= m_noItems ? wxNOT_FOUND : nItem;
}

#endif

