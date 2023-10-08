using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ChangeModelColor : MonoBehaviour
{
    public GameManager gameManager;
    private void Start()
    {
        transform.GetComponent<Button>().onClick.AddListener(ChangeMaterialColor);
    }
    public void ChangeMaterialColor()
    {
        for (int i = 0; i < gameManager.carMaterials.Length; i++)
        {
            gameManager.carMaterials[i].color = transform.GetComponent<Image>().color;
        }
    }
    private void OnDisable()
    {
        //����ʱ����ɫ����Ϊ��ɫ
        for (int i = 0; i < gameManager.carMaterials.Length; i++)
        {
            gameManager.carMaterials[i].color = Color.white;
        }
    }
}
