using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [Header("开始面板")]
    public GameObject StartPanel;       //开始面板
    public GameObject ControlPanel;     //控制面板
    public GameObject E5Car;            //汽车模型
    private Vector3 E5CarPos;           //记录汽车初始化的位置
    private Vector3 E5CarRot;           //记录汽车初始化的角度
    private Vector3 E5CarSc;            //记录汽车初始化的比例

    public Button StartBtn;             //开始按钮
    
    [Header("返回按钮")]
    public Button ReturnBtn;            //返回按钮
   
    [Header("开/关门按钮")]
    public Toggle DoorTog;              //开关门切换
    public GameObject leftDoor;
    public GameObject rightDoor;

    [Header("显示/隐藏参数按钮")]
    public Toggle ParamTog;             //显示隐藏参数切换
    public GameObject ParamObj;         //参数面板

    [Header("显示/隐藏外观按钮")]
    public Toggle CarShellTog;          //显示隐藏外观切换
    public GameObject CarShellObj;      //车身

    [Header("爆炸按钮")]
    public Toggle ExplodeTog;           //爆炸切换
    public GameObject[] ExplodeObj;     //爆炸部位  0左车门 1右车门 2车壳 3车头 4后备箱
    public GameObject[] startPosition;  //部位开始位置
    public GameObject[] movePoint;      //部位爆炸后移动的位置
    public float MoveSpeed;             //移动速度


    [Header("发动/关闭汽车按钮")]
    public Toggle StartUpTog;           //发动汽车切换
    public GameObject carLightObj;      //车灯

    [Header("开始/停止旋转按钮")]
    public Toggle RotateTog;            //发动汽车切换
    public float rotationSpeed;         //旋转速度
    private bool isRotate;              //判断是否可以进行旋转

    [Header("汽车模型材质球")]
    public Material[] carMaterials;

    void Awake()
    {
        OnInit();
        StartBtn.onClick.AddListener(OnClickStartBtn);
        ReturnBtn.onClick.AddListener(OnClickReturnBtn);
        DoorTog.onValueChanged.AddListener(OnValueChangeDoorTog);
        ParamTog.onValueChanged.AddListener(OnvalueChangeParamTog);
        CarShellTog.onValueChanged.AddListener(OnvalueChangeCarShellTog);
        ExplodeTog.onValueChanged.AddListener(OnvalueChangeExplodeTog);
        StartUpTog.onValueChanged.AddListener(OnvalueChangeStartUpTog);
        RotateTog.onValueChanged.AddListener(OnvalueChangeRotateTog);
    }

    void OnInit()
    {
        StartPanel.SetActive(true);
        ControlPanel.SetActive(false);
        E5Car.SetActive(false);
        //记录初始化汽车的位置角度比例
        E5CarPos = E5Car.transform.position;
        E5CarRot = E5Car.transform.rotation.eulerAngles;
        E5CarSc = E5Car.transform.localScale;
    }

    //点击开始按钮
    public void OnClickStartBtn()
    {
        StartPanel.gameObject.SetActive(false);
        ControlPanel.SetActive(true);
        E5Car.gameObject.SetActive(true);
        //每次点击开始按钮重新初始化模型位置角度比例
        E5Car.transform.position = E5CarPos;
        E5Car.transform.rotation = Quaternion.Euler(E5CarRot);
        E5Car.transform.localScale = E5CarSc;
    }
    //点击返回按钮
    public void OnClickReturnBtn()
    {
        StartPanel.gameObject.SetActive(true);
        ControlPanel.SetActive(false);
        E5Car.gameObject.SetActive(false);
    }
    //开关门切换按钮
    private void OnValueChangeDoorTog(bool isOn)
    {
        if (isOn)
        {
            leftDoor.GetComponent<Animator>().Play("LeftDoorOpen");
            rightDoor.GetComponent<Animator>().Play("RightDoorOpen");
            DoorTog.GetComponentInChildren<Text>().text = "关门";
        }
        else
        {
            leftDoor.GetComponent<Animator>().Play("LeftDoorClose");
            rightDoor.GetComponent<Animator>().Play("RightDoorClose");
            DoorTog.GetComponentInChildren<Text>().text = "开门";
        }
        //缺少汽车开门声
        DoorTog.GetComponent<AudioSource>().Play();
    }
    //显示/隐藏参数按钮
    private void OnvalueChangeParamTog(bool isOn)
    {
        if (isOn)
        {
            ParamTog.GetComponentInChildren<Text>().text = "隐藏参数";
            ParamObj.SetActive(true);
        }
        else
        {
            ParamTog.GetComponentInChildren<Text>().text = "显示参数";
            ParamObj.SetActive(false);
        }
    }
    //显示/隐藏外观按钮
    private void OnvalueChangeCarShellTog(bool isOn)
    {
        if (isOn)
        {
            CarShellTog.GetComponentInChildren<Text>().text = "显示外观";
            CarShellObj.SetActive(false);
        }
        else
        {
            CarShellTog.GetComponentInChildren<Text>().text = "隐藏外观";
            CarShellObj.SetActive(true);
        }
    }
    //爆炸按钮
    private void OnvalueChangeExplodeTog(bool isOn)
    {
        if (isOn)
        {
            //关闭汽车碰撞体 部件移动 打开部件碰撞体
            StartCoroutine(ChangeObjCollider(E5Car, 0f));
            for (int i = 0; i < ExplodeObj.Length; i++)
            {
                //部件位置移动
                StartCoroutine(MoveObj(ExplodeObj[i], movePoint[i]));

                //打开碰撞体
                StartCoroutine(ChangeObjCollider(ExplodeObj[i], 1f));
            }
        }
        else
        {
            //关闭部件碰撞体 部件移动 打开汽车碰撞体
            for (int i = 0; i < ExplodeObj.Length; i++)
            {
                //部件位置移动
                StartCoroutine(MoveObj(ExplodeObj[i], startPosition[i]));

                //关闭碰撞体
                StartCoroutine(ChangeObjCollider(ExplodeObj[i], 0f));
            }
            StartCoroutine(ChangeObjCollider(E5Car, 1f));
        }
    }
    //激活关闭汽车碰撞体
    IEnumerator ChangeObjCollider(GameObject go,float time)
    {
        yield return new WaitForSeconds(time);
        go.GetComponent<BoxCollider>().enabled = !go.GetComponent<BoxCollider>().enabled;
    }
    //移动部件协程
    IEnumerator MoveObj(GameObject go, GameObject point)
    {
        while (Vector3.Distance(go.transform.position, point.transform.position) > 0.005f)
        {
            go.transform.position = Vector3.MoveTowards(go.transform.position, point.transform.position, Time.deltaTime * MoveSpeed);
            go.transform.rotation = Quaternion.Slerp(go.transform.rotation, point.transform.rotation, MoveSpeed * Time.deltaTime*3);
            yield return null;
        }
    }


    //发动/关闭汽车按钮
    private void OnvalueChangeStartUpTog(bool isOn)
    {
        if (isOn)
        {
            StartUpTog.GetComponentInChildren<Text>().text = "关闭汽车";
            carLightObj.SetActive(true);
            //汽车发动时的引擎声
            StartUpTog.GetComponent<AudioSource>().Play();
        }
        else
        {
            StartUpTog.GetComponentInChildren<Text>().text = "发动汽车";
            carLightObj.SetActive(false);
        }
    }
    //开始/停止旋转按钮
    private void OnvalueChangeRotateTog(bool isOn)
    {
        if (isOn)
        {
            RotateTog.GetComponentInChildren<Text>().text = "停止旋转";
            isRotate = true;
            StartCoroutine(StartRotate());
        }
        else
        {
            RotateTog.GetComponentInChildren<Text>().text = "开始旋转";
            isRotate = false;
        }
    }
    //汽车旋转携程
    IEnumerator StartRotate()
    {
        yield return null;
        E5Car.transform.Rotate(Vector3.up * Time.deltaTime * rotationSpeed);
        if (isRotate) StartCoroutine(StartRotate());
    }


}
