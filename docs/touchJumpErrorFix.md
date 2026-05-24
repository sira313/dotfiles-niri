There's touchjump error in my thinkpad t495s, so i fix it with this
```bash
sudo micro /etc/modprobe.d/psmouse.conf
```
Add this line
```bash
options psmouse synaptics_intertouch=0
options psmouse elantech_smbus=1
```
Here's the results
```bash
systool -v -m psmouse

Module = "psmouse"

  Attributes:
    coresize            = "245760"
    initsize            = "0"
    initstate           = "live"
    refcnt              = "0"
    srcversion          = "5A7479DDE4FD38EC0F4493B"
    taint               = ""
    uevent              = <store method only>

  Parameters:
    a4tech_workaround   = "N"
    elantech_smbus      = "1"
    proto               = "auto"
    rate                = "100"
    resetafter          = "5"
    resolution          = "200"
    resync_time         = "0"
    smartscroll         = "Y"
    synaptics_intertouch= "0"

  Sections:
```