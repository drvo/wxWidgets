/////////////////////////////////////////////////////////////////////////////
// Name:        wx/x11/colour.h
// Purpose:     wxColour class
// Author:      Julian Smart, Robert Roebling
// Modified by:
// Created:     17/09/98
// RCS-ID:      $Id$
// Copyright:   (c) Julian Smart, Robert Roebling
// Licence:     wxWindows licence
/////////////////////////////////////////////////////////////////////////////

#ifndef _WX_COLOUR_H_
#define _WX_COLOUR_H_

#include "wx/defs.h"
#include "wx/object.h"
#include "wx/string.h"
#include "wx/gdiobj.h"
#include "wx/palette.h"

//-----------------------------------------------------------------------------
// classes
//-----------------------------------------------------------------------------

class WXDLLIMPEXP_CORE wxDC;
class WXDLLIMPEXP_CORE wxPaintDC;
class WXDLLIMPEXP_CORE wxBitmap;
class WXDLLIMPEXP_CORE wxWindow;

class WXDLLIMPEXP_CORE wxColour;

//-----------------------------------------------------------------------------
// wxColour
//-----------------------------------------------------------------------------

class WXDLLEXPORT wxColour: public wxGDIObject
{
public:
    // constructors
    // ------------

    // default
    wxColour() { }

    // from separate RGB
    wxColour( unsigned char red, unsigned char green, unsigned char blue );

    // from packed RGB
    wxColour( unsigned long colRGB ) { Set(colRGB); }

    // Implicit conversion from the colour name
    wxColour( const wxString &colourName ) { InitFromName(colourName); }
    wxColour( const char *colourName ) { InitFromName( wxString::FromAscii(colourName) ); }
#if wxUSE_UNICODE
    wxColour( const wxChar *colourName ) { InitFromName( wxString(colourName) ); }
#endif

    // Get colour from name or wxNullColour
    static wxColour CreateByName(const wxString& name);

    ~wxColour();

    bool Ok() const { return m_refData != NULL; }

    bool operator == ( const wxColour& col ) const;
    bool operator != ( const wxColour& col ) const { return !(*this == col); }

    void Set( unsigned char red, unsigned char green, unsigned char blue );
    void Set( unsigned long colRGB )
    {
        // We don't need to know sizeof(long) here because we assume that the three
        // least significant bytes contain the R, G and B values
        Set((unsigned char)colRGB,
            (unsigned char)(colRGB >> 8),
            (unsigned char)(colRGB >> 16));
    }

    unsigned char Red() const;
    unsigned char Green() const;
    unsigned char Blue() const;

    // Implementation part

    void CalcPixel( WXColormap cmap );
    unsigned long GetPixel() const;
    WXColor *GetColor() const;

    void InitFromName(const wxString& colourName);

protected:
    // ref counting code
    virtual wxObjectRefData *CreateRefData() const;
    virtual wxObjectRefData *CloneRefData(const wxObjectRefData *data) const;


private:
    DECLARE_DYNAMIC_CLASS(wxColour)
};

#endif

// _WX_COLOUR_H_
