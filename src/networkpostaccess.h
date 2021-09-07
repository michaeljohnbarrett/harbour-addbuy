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
    QNetworkRequest request;
    QByteArray responseText;
    QNetworkReply* reply;
    QVariant responseCode;

    Q_INVOKABLE void post(QString saveUrl, QByteArray saveData, QByteArray bearerSessionKey) {

        request.setUrl(saveUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Accept", "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);

        reply = connectionManager.post(request, saveData);

        connect(reply, &QNetworkReply::finished, [=]() {

            if (reply->error() == QNetworkReply::NoError) {

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode);

            }

            else { // handle error

                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode);

            }

        });

    }

signals:

    void finished(QByteArray responseText, QVariant responseCode);

};

#endif // NETWORKPOSTACCESS_H
