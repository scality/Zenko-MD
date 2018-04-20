'use strict'; // eslint-disable-line strict

const path = require('path');
const fs = require('fs');

const werelogs = require('werelogs');
const MetadataWrapper = require('arsenal')
      .storage.metadata.MetadataWrapper;
const Server = require('arsenal')
      .storage.metadata.proxy.Server;

const supportedDriver = {
    mem: true,
    file: true,
    mongodb: true,
};

function transformConfig(driver, config) {
    return {
        mem: config => config.mem,
        file: config => ({ metadataClient: config.file }),
        mongodb: config => ({ mongodb: config.mongodb }),
    }[driver](config);
}

function parseConfigurationFile(configurationFile) {
    let config;
    try {
        const data = fs.readFileSync(configurationFile,
                                     { encoding: 'utf-8' });
        config = JSON.parse(data);
    } catch (err) {
        throw new Error(`could not parse config file '${configurationFile}':` +
                        ` ${err.message}`);
    }
    return config;
}

function main() {
    const defaultConfigurationFile = path.join(__dirname, '../config.json');
    const configurationFile = process.env.MDP_CONFIG_FILE ||
          defaultConfigurationFile;
    const config = parseConfigurationFile(configurationFile);
    const driver = process.env.MDP_DRIVER || 'mem';
    if (!supportedDriver[driver]) {
        throw new Error(`Invalid Metadata driver '${driver}'`);
    }
    const logger = new werelogs.Logger('MetadataProxyServer',
                                       config.log.logLevel,
                                       config.log.dumpLevel);
    const metadataWrapper = new MetadataWrapper(driver,
                                                transformConfig(driver, config),
                                                null, logger);
    const proxyServer = new Server(
        metadataWrapper,
        {
            port: config.port,
            bindAddress: config.bindAddress,
            workers: config.workers,
        },
        logger);
    proxyServer.start(() => {
        logger.info('Metadata Proxy Server successfully started. ' +
                    `Using the ${metadataWrapper.implName} driver`);
    });
}

module.exports = main;
