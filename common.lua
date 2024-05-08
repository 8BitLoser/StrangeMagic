local common = {}

common.logger = require("logging.logger")
common.log = common.logger.getLogger("StrangeMagic") or "Logger Not Found"


return common

--local log = require("BeefStranger.StrangeMagic.common").log