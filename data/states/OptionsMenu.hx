import funkin.options.TreeMenuScreen;

var patchedMenus:Array<TreeMenuScreen> = [];

function postUpdate(elapsed)
{
    for (menu in tree)
    {
        if (menu == null) continue;

        for (obj in menu.members)
        {
            if (obj == null) continue;

            obj.x = menu.x;
        }
    }
}