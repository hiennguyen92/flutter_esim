package com.hiennv.flutter_esim

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.service.euicc.ICarrierEuiccProvisioningService
import android.service.euicc.IGetActivationCodeCallback

class CarrierEuiccProvisioningService : Service() {
    val ACTIVATION_CODE = "" // activation code.

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }



    private val binder = object : ICarrierEuiccProvisioningService.Stub () {
        override fun getActivationCode(callback: IGetActivationCodeCallback?) {
            // you can write your own logic to fetch activation code from somewhere.
            var activationCode : String = ACTIVATION_CODE
            callback?.onSuccess(activationCode)
        }

        override fun getActivationCodeForEid(eid: String?, callback: IGetActivationCodeCallback?) {
            var activationCode : String = ACTIVATION_CODE
            callback?.onSuccess(activationCode)
        }

    }
}