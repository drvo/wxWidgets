/////////////////////////////////////////////////////////////////////////////
// Name:        dialog.h
// Purpose:     wxDialog class
// Author:      AUTHOR
// Modified by:
// Created:     ??/??/98
// RCS-ID:      $Id$
// Copyright:   (c) AUTHOR
// Licence:   	wxWindows licence
/////////////////////////////////////////////////////////////////////////////

#ifndef _WX_DIALOG_H_
#define _WX_DIALOG_H_

#ifdef __GNUG__
#pragma interface "dialog.h"
#endif

#include "wx/panel.h"

WXDLLEXPORT_DATA(extern const char*) wxDialogNameStr;

// Dialog boxes
class WXDLLEXPORT wxDialog: public wxPanel
{
  DECLARE_DYNAMIC_CLASS(wxDialog)
public:

  wxDialog();

  // Constructor with a modal flag, but no window id - the old convention
  inline wxDialog(wxWindow *parent,
           const wxString& title, bool modal,
           int x = -1, int y= -1, int width = 500, int height = 500,
           long style = wxDEFAULT_DIALOG_STYLE,
           const wxString& name = wxDialogNameStr)
  {
      long modalStyle = modal ? wxDIALOG_MODAL : wxDIALOG_MODELESS ;
      Create(parent, -1, title, wxPoint(x, y), wxSize(width, height), style|modalStyle, name);
  }

  // Constructor with no modal flag - the new convention.
  inline wxDialog(wxWindow *parent, wxWindowID id,
           const wxString& title,
           const wxPoint& pos = wxDefaultPosition,
           const wxSize& size = wxDefaultSize,
           long style = wxDEFAULT_DIALOG_STYLE,
           const wxString& name = wxDialogNameStr)
  {
      Create(parent, id, title, pos, size, style, name);
  }

  bool Create(wxWindow *parent, wxWindowID id,
           const wxString& title, // bool modal = FALSE, // TODO make this a window style?
           const wxPoint& pos = wxDefaultPosition,
           const wxSize& size = wxDefaultSize,
           long style = wxDEFAULT_DIALOG_STYLE,
           const wxString& name = wxDialogNameStr);

  ~wxDialog();

  virtual bool Destroy();
  void SetSize(int x, int y, int width, int height, int sizeFlags = wxSIZE_AUTO);
  void SetClientSize(int width, int height);
  void GetPosition(int *x, int *y) const;
  bool Show(bool show);
  bool IsShown() const ;
  void Iconize(bool iconize);

  virtual bool IsIconized() const;
  void Fit();

  void SetTitle(const wxString& title);
  wxString GetTitle() const ;

  bool OnClose();
  void OnCharHook(wxKeyEvent& event);
  void OnPaint(wxPaintEvent& event);
  void OnCloseWindow(wxCloseEvent& event);

  void SetModal(bool flag);

  virtual void Centre(int direction = wxBOTH);
  virtual bool IsModal() const { return ((GetWindowStyleFlag() & wxDIALOG_MODAL) == wxDIALOG_MODAL); }

  virtual int ShowModal();
  virtual void EndModal(int retCode);

  // Standard buttons
  void OnOK(wxCommandEvent& event);
  void OnApply(wxCommandEvent& event);
  void OnCancel(wxCommandEvent& event);

  // Responds to colour changes
  void OnSysColourChanged(wxSysColourChangedEvent& event);

DECLARE_EVENT_TABLE()
};

#endif
    // _WX_DIALOG_H_
