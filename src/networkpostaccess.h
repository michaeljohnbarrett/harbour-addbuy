#ifndef NETWORKPOSTACCESS_H
#define NETWORKPOSTACCESS_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class NetworkPostAccess : public QNetworkAccessManager {

    Q_OBJECT

public:

    explicit NetworkPostAccess() { }

    QNetworkAccessManager connectionManager;
    QNetworkRequest saveTransactionRequest;
    QByteArray responseText;
    QNetworkReply* saveReply;
    QVariant responseCode;

    Q_INVOKABLE void post(QString saveUrl, QByteArray saveData, QByteArray bearerSessionKey) {

        saveTransactionRequest.setUrl(saveUrl);
        saveTransactionRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        saveTransactionRequest.setRawHeader("Accept", "application/json");
        saveTransactionRequest.setRawHeader("Authorization", bearerSessionKey);

        saveReply = connectionManager.post(saveTransactionRequest, saveData);

        connect(saveReply, &QNetworkReply::finished, [=]() {

            if(saveReply->error() == QNetworkReply::NoError) {

                responseText = saveReply->readAll();
                responseCode = saveReply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode);

            }

            else { // handle error

                responseCode = saveReply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode);

            }

        });

    }

signals:

    void finished(QByteArray responseText, QVariant responseCode);

};

#endif // NETWORKPOSTACCESS_H
