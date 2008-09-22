///////////////////////////////////////////////////////////////////////////////
// Name:        src/gtk/textentry.cpp
// Purpose:     wxTextEntry implementation for wxGTK
// Author:      Vadim Zeitlin
// Created:     2007-09-24
// RCS-ID:      $Id$
// Copyright:   (c) 2007 Vadim Zeitlin <vadim@wxwindows.org>
// Licence:     wxWindows licence
///////////////////////////////////////////////////////////////////////////////

// ============================================================================
// declarations
// ============================================================================

// ----------------------------------------------------------------------------
// headers
// ----------------------------------------------------------------------------

// for compilers that support precompilation, includes "wx.h".
#include "wx/wxprec.h"

#ifdef __BORLANDC__
    #pragma hdrstop
#endif

#if wxUSE_TEXTCTRL || wxUSE_COMBOBOX

#ifndef WX_PRECOMP
    #include "wx/window.h"
    #include "wx/textctrl.h"
#endif //WX_PRECOMP

#include "wx/textentry.h"

#include "wx/gtk/private.h"

// ============================================================================
// signal handlers implementation
// ============================================================================

extern "C"
{

// "insert_text" handler for GtkEntry
static void
wx_gtk_insert_text_callback(GtkEditable *editable,
                            const gchar * WXUNUSED(new_text),
                            gint WXUNUSED(new_text_length),
                            gint * WXUNUSED(position),
                            wxTextEntry *text)
{
    // we should only be called if we have a max len limit at all
    GtkEntry *entry = GTK_ENTRY (editable);

    wxCHECK_RET( entry->text_max_length, _T("shouldn't be called") );

    // check that we don't overflow the max length limit
    //
    // FIXME: this doesn't work when we paste a string which is going to be
    //        truncated
    if ( entry->text_length == entry->text_max_length )
    {
        // we don't need to run the base class version at all
        g_signal_stop_emission_by_name (editable, "insert_text");

        text->SendMaxLenEvent();
    }
}

} // extern "C"

// ============================================================================
// wxTextEntry implementation
// ============================================================================

// ----------------------------------------------------------------------------
// text operations
// ----------------------------------------------------------------------------

void wxTextEntry::WriteText(const wxString& value)
{
    GtkEditable * const edit = GetEditable();

    // remove the selection if there is one and suppress the text change event
    // generated by this: we only want to generate one event for this change,
    // not two
    {
        EventsSuppressor noevents(this);
        gtk_editable_delete_selection(edit);
    }

    // insert new text at the cursor position
    gint len = gtk_editable_get_position(edit);
    gtk_editable_insert_text
    (
        edit,
        wxGTK_CONV_FONT(value, GetEditableWindow()->GetFont()),
        -1,     // text: length: compute it using strlen()
        &len    // will be updated to position after the text end
    );

    // and move cursor to the end of new text
    gtk_editable_set_position(edit, len);
}

wxString wxTextEntry::GetValue() const
{
    const wxGtkString value(gtk_editable_get_chars(GetEditable(), 0, -1));

    return wxGTK_CONV_BACK_FONT(value, GetEditableWindow()->GetFont());
}

void wxTextEntry::Remove(long from, long to)
{
    gtk_editable_delete_text(GetEditable(), from, to);
}

// ----------------------------------------------------------------------------
// clipboard operations
// ----------------------------------------------------------------------------

void wxTextEntry::Copy()
{
    gtk_editable_copy_clipboard(GetEditable());
}

void wxTextEntry::Cut()
{
    gtk_editable_cut_clipboard(GetEditable());
}

void wxTextEntry::Paste()
{
    gtk_editable_paste_clipboard(GetEditable());
}

// ----------------------------------------------------------------------------
// undo/redo
// ----------------------------------------------------------------------------

void wxTextEntry::Undo()
{
    // TODO: not implemented
}

void wxTextEntry::Redo()
{
    // TODO: not implemented
}

bool wxTextEntry::CanUndo() const
{
    return false;
}

bool wxTextEntry::CanRedo() const
{
    return false;
}

// ----------------------------------------------------------------------------
// insertion point
// ----------------------------------------------------------------------------

void wxTextEntry::SetInsertionPoint(long pos)
{
    gtk_editable_set_position(GetEditable(), pos);
}

long wxTextEntry::GetInsertionPoint() const
{
    return gtk_editable_get_position(GetEditable());
}

long wxTextEntry::GetLastPosition() const
{
    // this can't be implemented for arbitrary GtkEditable so only do it for
    // GtkEntries
    GtkEntry * const entry = GTK_ENTRY(GetEditable());

    return entry ? entry->text_length : - 1;
}

// ----------------------------------------------------------------------------
// selection
// ----------------------------------------------------------------------------

void wxTextEntry::SetSelection(long from, long to)
{
    // in wx convention, (-1, -1) means the entire range but GTK+ translates -1
    // (or any negative number for that matter) into last position so we need
    // to translate manually
    if ( from == -1 && to == -1 )
        from = 0;

    // for compatibility with MSW, exchange from and to parameters so that the
    // insertion point is set to the start of the selection and not its end as
    // GTK+ does by default
    gtk_editable_select_region(GetEditable(), to, from);
}

void wxTextEntry::GetSelection(long *from, long *to) const
{
    gint start, end;
    if ( gtk_editable_get_selection_bounds(GetEditable(), &start, &end) )
    {
        // the output must always be in order, although in GTK+ it isn't
        if ( start > end )
        {
            gint tmp = start;
            start = end;
            end = tmp;
        }
    }
    else // no selection
    {
        // for compatibility with MSW return the empty selection at cursor
        start =
        end = GetInsertionPoint();
    }

    if ( from )
        *from = start;

    if ( to )
        *to = end;
}

// ----------------------------------------------------------------------------
// auto completion
// ----------------------------------------------------------------------------

bool wxTextEntry::AutoComplete(const wxArrayString& choices)
{
    GtkEntry * const entry = GTK_ENTRY(GetEditable());
    wxCHECK_MSG(entry, false, "auto completion doesn't work with this control");

    GtkListStore * const store = gtk_list_store_new(1, G_TYPE_STRING);
    GtkTreeIter iter;

    for ( wxArrayString::const_iterator i = choices.begin();
          i != choices.end();
          ++i )
    {
        gtk_list_store_append(store, &iter);
        gtk_list_store_set(store, &iter,
                           0, (const gchar *)i->utf8_str(),
                           -1);
    }

    GtkEntryCompletion * const completion = gtk_entry_completion_new();
    gtk_entry_completion_set_model(completion, GTK_TREE_MODEL(store));
    gtk_entry_completion_set_text_column(completion, 0);
    gtk_entry_set_completion(entry, completion);
    g_object_unref(completion);
    return true;
}

// ----------------------------------------------------------------------------
// editable status
// ----------------------------------------------------------------------------

bool wxTextEntry::IsEditable() const
{
    return gtk_editable_get_editable(GetEditable());
}

void wxTextEntry::SetEditable(bool editable)
{
    gtk_editable_set_editable(GetEditable(), editable);
}

// ----------------------------------------------------------------------------
// max text length
// ----------------------------------------------------------------------------

void wxTextEntry::SetMaxLength(unsigned long len)
{
    GtkEntry * const entry = GTK_ENTRY(GetEditable());
    if ( !entry )
        return;

    gtk_entry_set_max_length(entry, len);

    // there is a bug in GTK+ 1.2.x: "changed" signal is emitted even if we had
    // tried to enter more text than allowed by max text length and the text
    // wasn't really changed
    //
    // to detect this and generate TEXT_MAXLEN event instead of TEXT_CHANGED
    // one in this case we also catch "insert_text" signal
    //
    // when max len is set to 0 we disconnect our handler as it means that we
    // shouldn't check anything any more
    if ( len )
    {
        g_signal_connect
        (
            entry,
            "insert_text",
            G_CALLBACK(wx_gtk_insert_text_callback),
            this
        );
    }
    else // no max length
    {
        g_signal_handlers_disconnect_by_func
        (
            entry,
            (gpointer)wx_gtk_insert_text_callback,
            this
        );
    }
}

void wxTextEntry::SendMaxLenEvent()
{
    // remember that the next changed signal is to be ignored to avoid
    // generating a dummy wxEVT_COMMAND_TEXT_UPDATED event
    //IgnoreNextTextUpdate();

    wxWindow * const win = const_cast<wxWindow *>(GetEditableWindow());
    wxCommandEvent event(wxEVT_COMMAND_TEXT_MAXLEN, win->GetId());
    event.SetEventObject(win);
    event.SetString(GetValue());
    win->HandleWindowEvent(event);
}

#endif // wxUSE_TEXTCTRL || wxUSE_COMBOBOX
