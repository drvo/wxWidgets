
"""Renamer stub: provides a way to drop the wx prefix from wxPython objects."""

__cvsid__ = "$Id$"
__revision__ = "$Revision$"[11:-2]

from wx import _rename
from wxPython.lib.mixins import rubberband
_rename(globals(), rubberband.__dict__, modulename='lib.mixins.rubberband')
del rubberband
del _rename
