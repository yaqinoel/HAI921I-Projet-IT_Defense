// Bevelsmith UI kit importer for Unity. Keep it in an Editor folder.
// Every PNG that sits next to a bevelsmith_slices.json file is imported as a pixel-perfect sprite
// (Point filter, no compression, no mipmaps) with its 9-slice borders set, so UI Images can use
// Image Type = Sliced or Tiled. Cursor images are imported as cursors for Cursor.SetCursor.
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Bevelsmith
{
    public class BevelsmithImporter : AssetPostprocessor
    {
        const string SliceFile = "bevelsmith_slices.json";

        [System.Serializable] class Piece { public string name; public int left, top, right, bottom; }
        [System.Serializable] class CursorInfo { public string name; public int x, y; }
        [System.Serializable] class Kit { public float pixelsPerUnit = 100; public Piece[] pieces; public CursorInfo[] cursors; }

        public override uint GetVersion() { return 2; }

        void OnPreprocessTexture()
        {
            string json = Path.Combine(Path.GetDirectoryName(assetPath), SliceFile);
            if (!File.Exists(json)) return;
            Kit kit = JsonUtility.FromJson<Kit>(File.ReadAllText(json));
            string name = Path.GetFileNameWithoutExtension(assetPath);
            var importer = (TextureImporter)assetImporter;

            bool isCursor = false;
            if (kit.cursors != null)
                foreach (CursorInfo c in kit.cursors) if (c.name == name) isCursor = true;

            importer.textureType = isCursor ? TextureImporterType.Cursor : TextureImporterType.Sprite;
            importer.filterMode = FilterMode.Point;
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.mipmapEnabled = false;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Clamp;
            if (isCursor)
            {
                importer.isReadable = true;
                return;
            }
            importer.spriteImportMode = SpriteImportMode.Single;
            importer.spritePixelsPerUnit = kit.pixelsPerUnit;
            // Full Rect mesh: SpriteRenderers in Sliced or Tiled draw mode need it (the default tight mesh warns).
            var settings = new TextureImporterSettings();
            importer.ReadTextureSettings(settings);
            settings.spriteMeshType = SpriteMeshType.FullRect;
            importer.SetTextureSettings(settings);
            if (kit.pieces != null)
                foreach (Piece p in kit.pieces)
                    if (p.name == name) importer.spriteBorder = new Vector4(p.left, p.bottom, p.right, p.top);
        }

        [MenuItem("Tools/Bevelsmith/Reimport UI kits")]
        static void ReimportKits()
        {
            int count = 0;
            foreach (string guid in AssetDatabase.FindAssets("t:Texture2D"))
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (!File.Exists(Path.Combine(Path.GetDirectoryName(path), SliceFile))) continue;
                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
                count++;
            }
            Debug.Log("Bevelsmith: reimported " + count + " UI kit images.");
        }
    }
}
