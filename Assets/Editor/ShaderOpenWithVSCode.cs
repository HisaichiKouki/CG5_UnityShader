// Assets/Editor/ShaderOpenWithVSCode.cs
#if UNITY_EDITOR
using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEngine;

public static class ShaderOpenWithVSCode
{
    // VS Code �̋N���R�}���h�𐄑��iPATH�D��j�B�K�v�Ȃ玩���̊��ɍ��킹�ČŒ�p�X��ݒ肵�Ă��������B
    // ��: Windows �Œ�p�X: @"C:\Users\<User>\AppData\Local\Programs\Microsoft VS Code\Code.exe"
    //     macOS �Œ�p�X:  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    private static string ResolveVSCodeCommand()
    {
#if UNITY_EDITOR_WIN
        // 1) PATH �� "code" ��D��
        return @"C:\Users\k023g\AppData\Local\Programs\Microsoft VS Code\Code.exe"; // �����ĂȂ��ꍇ�͉��̃t�H�[���o�b�N�Ɏ��s���邱�Ƃ�����̂ŕK�v�Ȃ�Œ�p�X��
#elif UNITY_EDITOR_OSX
        return "code"; // mac ����{ "Shell Command: Install 'code' command in PATH" �����s���Ă���
#else
        return "code";
#endif
    }

    // VS Code�ŊJ�������g���q
    private static readonly string[] _vscodeExts = new[]
    {
        ".shader", ".hlsl", ".cginc", ".compute", ".glslinc"
    };

    [OnOpenAsset]
    public static bool OnOpenAsset(int instanceID, int line)
    {
        var obj = EditorUtility.InstanceIDToObject(instanceID);
        if (obj == null) return false;

        var assetPath = AssetDatabase.GetAssetPath(obj);
        if (string.IsNullOrEmpty(assetPath)) return false;

        var ext = Path.GetExtension(assetPath).ToLowerInvariant();
        // Shader�n���� VS Code �Ƀ��_�C���N�g
        if (System.Array.IndexOf(_vscodeExts, ext) < 0) return false;

        var fullPath = Path.GetFullPath(assetPath);

        // VS Code �̃R�}���h����
        var codeCmd = ResolveVSCodeCommand();

        // VS Code �� -g �I�v�V������ �s�ԍ� �t���I�[�v��
        // �s�ԍ��� 0 �ȉ��Ȃ�t���Ȃ�
        var args = (line > 0)
            ? $"-g \"{fullPath}:{line}\""
            : $"\"{fullPath}\"";

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = codeCmd,
                Arguments = args,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            Process.Start(psi);

            // ������ true ��Ԃ��� Unity ����̃I�[�v�������̓L�����Z�������i��VS Code �����ŊJ���j
            return true;
        }
        catch (System.Exception e)
        {
            UnityEngine.Debug.LogWarning($"VS Code �N���Ɏ��s���܂����BPATH �� 'code' ��ǉ����邩�A�X�N���v�g���ŌŒ�p�X�ɂ��Ă��������B\n{e}");
            return false; // ���s���͊���̃G�f�B�^�Ƀt�H�[���o�b�N
        }
    }
}
#endif
