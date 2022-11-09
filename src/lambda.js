'use strict';

const S3Unzip = require('s3-unzip');

const handler = async (event) => {
  const {
    Records: [
      {
        s3: {
          bucket: {
            name: bucketName,
          },
          object: {
            key: keyName,
          },
        },
      },
    ],
  } = event;

  try {
    const success = await new Promise((resolve, reject) => {
      new S3Unzip({
        bucket: bucketName,
        file: keyName,
        verbose: true,
      }, (err, success) => {
        if (err) {
          reject(err);
        } else {
          resolve(success);
        }
      });
    });
    console.log('Success', success);
  } catch (err) {
    console.error(`${bucketName}/${keyName} - Error:`, err.message);
  }
};

module.exports = {
  handler,
};
