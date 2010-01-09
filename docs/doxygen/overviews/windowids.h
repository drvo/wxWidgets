/////////////////////////////////////////////////////////////////////////////
// Name:        windowids.h
// Purpose:     topic overview
// Author:      wxWidgets team
// RCS-ID:      $Id$
// Licence:     wxWindows license
/////////////////////////////////////////////////////////////////////////////

/**

@page overview_windowids Window IDs

@li @ref overview_windowids_intro
@li @ref overview_windowids_type
@li @ref overview_windowids_using

@see

@li wxIdManager
@li wxWindow::NewControlId
@li wxWindow::UnreserveControlId


<hr>


@section overview_windowids_intro Introduction

Various controls and other parts of wxWidgets need an ID.  Sometimes the ID may
be directly provided by the user or have a predefined value, such as
@c wxID_OPEN. Often, however, the value of the ID is unimportant and is created
automatically by calling wxWindow::NewControlId or by passing @c wxID_ANY as
the ID of an object.

There are two ways to generate an ID.  One way is to start at a negative
number, and for each new ID, return the next smallest number.  This is fine for
systems that can use the full range of negative numbers for IDs, as this
provides more than enough IDs and it would take a very very long time to run
out and wrap around.  However, some systems can not use the full range of the
ID value. Windows, for example, can only use 16 bit IDs, and only has about
32000 possible automatic IDs that can be generated by wxWindow::NewControlId.
If the program runs long enough, depending on the program itself, using this
first method would cause the IDs to wrap around into the positive ID range and
cause possible clashes with any directly specified ID values.

The other way is to keep track of the IDs returned by wxWindow::NewControlId
and don't return them again until the ID is completely free and not being used
by any other objects.  This will make sure that the ID values do not clash with
one another.  This is accomplished by keeping a reference count for each of the
IDs that can possibly be returned by wxWindow::NewControlId. Other IDs are not
reference counted.


@section overview_windowids_type Data Types

A wxWindowID is just the integer type for a window ID.  It should be used
almost everywhere.  To help keep track of the count for the automatically
generated IDs, a new type, wxWindowIDRef exists, that can take the place of
wxWindowID where needed. When an ID is first created, it is marked as reserved.
When assigning it to a wxWindowIDRef, the usage count of the ID is increased,
or set to 1 if it is currently reserved.  Assigning the same ID to several
wxWindowIDRefs will keep track of the count. As the wxWindowIDRef gets
destroyed or its value changes, it will decrease the count of the used ID. When
there are no more wxWindowIDRef types with the created ID, the ID is considered
free and can then be used again by wxWindow::NewControlId.

If a created ID is not assigned to a wxWindowIDRef, then it remains reserved
until it is unreserved manually with wxWindow::UnreserveControlId. However, if
it is assigned to a wxWindowIDRef, then it will be unreserved automatically and
will be considered free when the count is 0, and should NOT be manually
unreserved.

wxWindowIDRef can store both automatic IDs from wxWindow::NewControlId and
normal IDs.  Reference counting is only done for the automatic IDs.  Also,
wxWindowIDRef has conversion operators that allow it to be treated just like a
wxWindowID.


@section overview_windowids_using Using wxWindowIDRef

A wxWindowIDRef should be used in place of a wxWindowID where you want to make
sure the ID is not created again by wxWindow::NewControlId at least until the
wxWindowIDRef is destroyed, usually when the associated object is destroyed.
This is done already for windows, menu items, and tool bar items. It should
only be used in the main thread, as it is not thread safe.

*/

