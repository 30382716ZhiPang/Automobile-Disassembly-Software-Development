using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [Header("��ʼ���")]
    public GameObject StartPanel;       //��ʼ���
    public GameObject ControlPanel;     //�������
    public GameObject E5Car;            //����ģ��
    private Vector3 E5CarPos;           //��¼������ʼ����λ��
    private Vector3 E5CarRot;           //��¼������ʼ���ĽǶ�
    private Vector3 E5CarSc;            //��¼������ʼ���ı���

    public Button StartBtn;             //��ʼ��ť
    
    [Header("���ذ�ť")]
    public Button ReturnBtn;            //���ذ�ť
   
    [Header("��/���Ű�ť")]
    public Toggle DoorTog;              //�������л�
    public GameObject leftDoor;
    public GameObject rightDoor;

    [Header("��ʾ/���ز�����ť")]
    public Toggle ParamTog;             //��ʾ���ز����л�
    public GameObject ParamObj;         //�������

    [Header("��ʾ/������۰�ť")]
    public Toggle CarShellTog;          //��ʾ��������л�
    public GameObject CarShellObj;      //����

    [Header("��ը��ť")]
    public Toggle ExplodeTog;           //��ը�л�
    public GameObject[] ExplodeObj;     //��ը��λ  0���� 1�ҳ��� 2���� 3��ͷ 4����
    public GameObject[] startPosition;  //��λ��ʼλ��
    public GameObject[] movePoint;      //��λ��ը���ƶ���λ��
    public float MoveSpeed;             //�ƶ��ٶ�


    [Header("����/�ر�������ť")]
    public Toggle StartUpTog;           //���������л�
    public GameObject carLightObj;      //����

    [Header("��ʼ/ֹͣ��ת��ť")]
    public Toggle RotateTog;            //���������л�
    public float rotationSpeed;         //��ת�ٶ�
    private bool isRotate;              //�ж��Ƿ���Խ�����ת

    [Header("����ģ�Ͳ�����")]
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
        //��¼��ʼ��������λ�ýǶȱ���
        E5CarPos = E5Car.transform.position;
        E5CarRot = E5Car.transform.rotation.eulerAngles;
        E5CarSc = E5Car.transform.localScale;
    }

    //�����ʼ��ť
    public void OnClickStartBtn()
    {
        StartPanel.gameObject.SetActive(false);
        ControlPanel.SetActive(true);
        E5Car.gameObject.SetActive(true);
        //ÿ�ε����ʼ��ť���³�ʼ��ģ��λ�ýǶȱ���
        E5Car.transform.position = E5CarPos;
        E5Car.transform.rotation = Quaternion.Euler(E5CarRot);
        E5Car.transform.localScale = E5CarSc;
    }
    //������ذ�ť
    public void OnClickReturnBtn()
    {
        StartPanel.gameObject.SetActive(true);
        ControlPanel.SetActive(false);
        E5Car.gameObject.SetActive(false);
    }
    //�������л���ť
    private void OnValueChangeDoorTog(bool isOn)
    {
        if (isOn)
        {
            leftDoor.GetComponent<Animator>().Play("LeftDoorOpen");
            rightDoor.GetComponent<Animator>().Play("RightDoorOpen");
            DoorTog.GetComponentInChildren<Text>().text = "����";
        }
        else
        {
            leftDoor.GetComponent<Animator>().Play("LeftDoorClose");
            rightDoor.GetComponent<Animator>().Play("RightDoorClose");
            DoorTog.GetComponentInChildren<Text>().text = "����";
        }
        //ȱ������������
        DoorTog.GetComponent<AudioSource>().Play();
    }
    //��ʾ/���ز�����ť
    private void OnvalueChangeParamTog(bool isOn)
    {
        if (isOn)
        {
            ParamTog.GetComponentInChildren<Text>().text = "���ز���";
            ParamObj.SetActive(true);
        }
        else
        {
            ParamTog.GetComponentInChildren<Text>().text = "��ʾ����";
            ParamObj.SetActive(false);
        }
    }
    //��ʾ/������۰�ť
    private void OnvalueChangeCarShellTog(bool isOn)
    {
        if (isOn)
        {
            CarShellTog.GetComponentInChildren<Text>().text = "��ʾ���";
            CarShellObj.SetActive(false);
        }
        else
        {
            CarShellTog.GetComponentInChildren<Text>().text = "�������";
            CarShellObj.SetActive(true);
        }
    }
    //��ը��ť
    private void OnvalueChangeExplodeTog(bool isOn)
    {
        if (isOn)
        {
            //�ر�������ײ�� �����ƶ� �򿪲�����ײ��
            StartCoroutine(ChangeObjCollider(E5Car, 0f));
            for (int i = 0; i < ExplodeObj.Length; i++)
            {
                //����λ���ƶ�
                StartCoroutine(MoveObj(ExplodeObj[i], movePoint[i]));

                //����ײ��
                StartCoroutine(ChangeObjCollider(ExplodeObj[i], 1f));
            }
        }
        else
        {
            //�رղ�����ײ�� �����ƶ� ��������ײ��
            for (int i = 0; i < ExplodeObj.Length; i++)
            {
                //����λ���ƶ�
                StartCoroutine(MoveObj(ExplodeObj[i], startPosition[i]));

                //�ر���ײ��
                StartCoroutine(ChangeObjCollider(ExplodeObj[i], 0f));
            }
            StartCoroutine(ChangeObjCollider(E5Car, 1f));
        }
    }
    //����ر�������ײ��
    IEnumerator ChangeObjCollider(GameObject go,float time)
    {
        yield return new WaitForSeconds(time);
        go.GetComponent<BoxCollider>().enabled = !go.GetComponent<BoxCollider>().enabled;
    }
    //�ƶ�����Э��
    IEnumerator MoveObj(GameObject go, GameObject point)
    {
        while (Vector3.Distance(go.transform.position, point.transform.position) > 0.005f)
        {
            go.transform.position = Vector3.MoveTowards(go.transform.position, point.transform.position, Time.deltaTime * MoveSpeed);
            go.transform.rotation = Quaternion.Slerp(go.transform.rotation, point.transform.rotation, MoveSpeed * Time.deltaTime*3);
            yield return null;
        }
    }


    //����/�ر�������ť
    private void OnvalueChangeStartUpTog(bool isOn)
    {
        if (isOn)
        {
            StartUpTog.GetComponentInChildren<Text>().text = "�ر�����";
            carLightObj.SetActive(true);
            //��������ʱ��������
            StartUpTog.GetComponent<AudioSource>().Play();
        }
        else
        {
            StartUpTog.GetComponentInChildren<Text>().text = "��������";
            carLightObj.SetActive(false);
        }
    }
    //��ʼ/ֹͣ��ת��ť
    private void OnvalueChangeRotateTog(bool isOn)
    {
        if (isOn)
        {
            RotateTog.GetComponentInChildren<Text>().text = "ֹͣ��ת";
            isRotate = true;
            StartCoroutine(StartRotate());
        }
        else
        {
            RotateTog.GetComponentInChildren<Text>().text = "��ʼ��ת";
            isRotate = false;
        }
    }
    //������תЯ��
    IEnumerator StartRotate()
    {
        yield return null;
        E5Car.transform.Rotate(Vector3.up * Time.deltaTime * rotationSpeed);
        if (isRotate) StartCoroutine(StartRotate());
    }


}
