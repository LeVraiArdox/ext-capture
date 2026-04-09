#include <QQmlExtensionPlugin>
#include "ExtCaptureItem.h"

class ExtCapturePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char* /*uri*/) override
    {
        // Nothing to do manually here.
    }
};

#include "plugin.moc"
