#!/bin/bash
# Background sync for Michael's UniSQ Marks
/usr/bin/rclone bisync ~/UniSQ_Drive/ unisq_gdrive:/ --verbose --check-access --conflict-resolve newer
