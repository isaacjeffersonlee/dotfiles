
import ranger.api
import subprocess
from ranger.api.commands import *


class fzf(Command):
    """:fzf
    Uses fzf to find directory of file and cd to it.
    """

    def execute(self):
        # Note: fzfh is a custom script I wrote
        # and added to path so that calling 
        path = subprocess.check_output("fzfh")
        path = path.decode("utf-8", "ignore")
        path = path.rstrip('\n')
        self.fm.execute_console("shell xdg-open " + path)

