/////////////////////////////////////////////////////////////////////////////
// Name:        richtext/richtexthtml.h
// Purpose:     documentation for wxRichTextHTMLHandler class
// Author:      wxWidgets team
// RCS-ID:      $Id$
// Licence:     wxWindows license
/////////////////////////////////////////////////////////////////////////////

/**
    @class wxRichTextHTMLHandler
    @headerfile richtexthtml.h wx/richtext/richtexthtml.h

    Handles HTML output (only) for wxRichTextCtrl content.

    The most flexible way to use this class is to create a temporary object and call
    its functions directly, rather than use wxRichTextBuffer::SaveFile or
    wxRichTextCtrl::SaveFile.

    Image handling requires a little extra work from the application, to choose an
    appropriate image format for the target HTML viewer and to clean up the
    temporary images
    later. If you are planning to load the HTML into a standard web browser, you can
    specify the handler flag wxRICHTEXT_HANDLER_SAVE_IMAGES_TO_BASE64 (the default)
    and no extra work is required: the images will be written with the HTML.

    However, if you want wxHTML compatibility, you will need to use
    wxRICHTEXT_HANDLER_SAVE_IMAGES_TO_MEMORY
    or wxRICHTEXT_HANDLER_SAVE_IMAGES_TO_FILES. In this case, you must either call
    wxRichTextHTMLHandler::DeleteTemporaryImages before
    the next load operation, or you must store the image
    locations and delete them yourself when appropriate. You can call
    wxRichTextHTMLHandler::GetTemporaryImageLocations to
    get the array of temporary image names.

    @library{wxrichtext}
    @category{FIXME}
*/
class wxRichTextHTMLHandler : public wxRichTextFileHandler
{
public:
    /**
        ,  wxString&@e ext = wxT("html"), @b int@e type = wxRICHTEXT_TYPE_HTML)
        Constructor.
    */
    wxRichTextHTMLHandler() const;

    /**
        Clears the image locations generated by the last operation.
    */
    void ClearTemporaryImageLocations();

    //@{
    /**
        Delete the in-memory or temporary files generated by the last operation. This
        is a static
        function that can be used to delete the saved locations from an earlier
        operation,
        for example after the user has viewed the HTML file.
    */
    bool DeleteTemporaryImages();
    bool DeleteTemporaryImages(int flags,
                               const wxArrayString& imageLocations);
    //@}

    /**
        Saves the buffer content to the HTML stream.
    */
    bool DoSaveFile(wxRichTextBuffer* buffer, wxOutputStream& stream);

    /**
        Returns the mapping for converting point sizes to HTML font sizes.
    */
    wxArrayInt GetFontSizeMapping();

    /**
        Returns the directory used to store temporary image files.
    */
    const wxString GetTempDir() const;

    /**
        Returns the image locations for the last operation.
    */
    const wxArrayString GetTemporaryImageLocations() const;

    /**
        Reset the file counter, in case, for example, the same names are required each
        time
    */
    void SetFileCounter(int counter);

    /**
        Sets the mapping for converting point sizes to HTML font sizes.
        There should be 7 elements, one for each HTML font size, each element
        specifying the maximum point size for that
        HTML font size.
        For example:
    */
    void SetFontSizeMapping(const wxArrayInt& fontSizeMapping);

    /**
        Sets the directory for storing temporary files. If empty, the system
        temporary directory will be used.
    */
    void SetTempDir(const wxString& tempDir);

    /**
        Sets the list of image locations generated by the last operation.
    */
    void SetTemporaryImageLocations(const wxArrayString& locations);
};
