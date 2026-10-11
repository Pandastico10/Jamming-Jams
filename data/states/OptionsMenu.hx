
function postUpdate(elapsed)
{
    for (menu in tree)
    {
        for (obj in menu.members)
        {
            obj.x = menu.x;
        }
    }
}